{-# LANGUAGE RecordWildCards #-}

module VibeCode.Scan where

import VibeCode.Agents
import VibeCode.Logging
import VibeCode.Types

import Control.Monad
import Data.List
import Data.Maybe
import System.Directory
import System.FilePath
import System.FilePattern.Directory
import System.IO.Temp
import System.Process

scanHackagePackage ::
     String
  -> Bool
  -> Bool
  -> Bool
  -> IO ScanResult
scanHackagePackage pkg scanFiles scanHistory keeDirectory = withTmp $ \tmp -> do
  when keeDirectory $ logStderr $ "Working dir: " <> tmp
  withCurrentDirectory tmp $ callProcess "cabal" ["get", "--source-repository=head", pkg]
  (d:_) <- listDirectory tmp
  let cabal_dir = tmp </> d

  resultAgent <- fmap catMaybes $ forM agents (scanAgent cabal_dir scanFiles scanHistory)

  pure $ ScanResult {..}
 where
  withTmp action =
    if keeDirectory
    then do
      tmp <- getCanonicalTemporaryDirectory
      tmpUnique <- createTempDirectory tmp "vibecode-scanner"
      action tmpUnique
    else withSystemTempDirectory "vibecode-scanner" action


scanAgent :: FilePath -> Bool -> Bool -> Agent -> IO (Maybe AgentResult)
scanAgent dir scanFiles scanHistory Agent{..} = do
  let arName = aiName

  arFiles <-
    if scanFiles
    then fmap catMaybes $ forM aiFiles $ \f -> do
           fExists <- doesFileExist (dir </> f)
           if fExists
           then pure (Just f)
           else pure Nothing
    else pure []

  arDirectories <-
    if scanFiles
    then fmap catMaybes $ forM aiDirectories $ \d -> do
           dExists <- doesDirectoryExist (dir </> d)
           if dExists
           then pure (Just d)
           else pure Nothing
    else pure []

  commitHashes <-
    if scanHistory
    then forM aiGitNeedles (findGetNeedle dir)
    else pure []

  let arCommits = length (nub commitHashes)

  let hit =  not (null arFiles)
          || not (null arDirectories)
          || not (arCommits == 0)

  if hit
  then pure (Just AgentResult{..})
  else pure Nothing

findGetNeedle :: FilePath -> GitNeedle -> IO [String]
findGetNeedle dir needle =
  case needle of
    GitCommitMessage m -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h", "--grep", m] ""
      pure (lines out)
    GitAuthor a -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h", "--author", a] ""
      pure (lines out)

