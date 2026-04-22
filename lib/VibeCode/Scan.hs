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
     String  -- ^ pkg name
  -> Bool    -- ^ verbose
  -> Bool    -- ^ scan files
  -> Bool    -- ^ scan history
  -> Bool    -- ^ keep directories
  -> IO ScanResult
scanHackagePackage pkg verbose scanFiles scanHistory keeDirectory = withTmp $ \tmp -> do
  when keeDirectory $ logStderr $ "Working dir: " <> tmp
  withCurrentDirectory tmp $ callProcess "cabal" ["get", "--verbose=0", "--source-repository=head", pkg]
  (d:_) <- listDirectory tmp
  let cabal_dir = tmp </> d

  resultAgent <- fmap catMaybes $ forM agents (scanAgent cabal_dir verbose scanFiles scanHistory)

  pure $ ScanResult {..}
 where
  withTmp action =
    if keeDirectory
    then do
      tmp <- getCanonicalTemporaryDirectory
      tmpUnique <- createTempDirectory tmp "vibecode-scanner"
      action tmpUnique
    else withSystemTempDirectory "vibecode-scanner" action


scanAgent ::
     FilePath  -- ^ working directory
  -> Bool      -- ^ verbose
  -> Bool      -- ^ scan files
  -> Bool      -- ^ scan history
  -> Agent
  -> IO (Maybe AgentResult)
scanAgent dir verbose scanFiles scanHistory Agent{..} = do
  let arName = aiName

  arFiles <-
    if scanFiles
    then fmap catMaybes $ forM aiFiles $ \f -> do
           fExists <- doesFileExist (dir </> f)
           if fExists
           then do
             logDebug verbose $ "Found " <> f
             pure (Just f)
           else pure Nothing
    else pure []

  arDirectories <-
    if scanFiles
    then fmap catMaybes $ forM aiDirectories $ \d -> do
           dExists <- doesDirectoryExist (dir </> d)
           if dExists
           then do
             logDebug verbose $ "Found " <> d
             pure (Just d)
           else pure Nothing
    else pure []

  commitHashes <-
    if scanHistory
    then mconcat <$> forM aiGitNeedles (findGetNeedle dir verbose)
    else pure []

  let arCommits = length (nub commitHashes)

  let hit =  not (null arFiles)
          || not (null arDirectories)
          ||     (arCommits > 0)

  if hit
  then do
    logDebug verbose $ "Found agent " <> aiName
    pure (Just AgentResult{..})
  else pure Nothing

findGetNeedle ::
     FilePath     -- ^ working directory
  -> Bool         -- ^ verbose
  -> GitNeedle    -- ^ git needle
  -> IO [String]
findGetNeedle dir verbose needle =
  case needle of
    GitCommitMessage m -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h", "--grep", m] ""
      let l = lines out
      when (length l > 0) $ logDebug verbose $ "Found commit message " <> m
      pure l
    GitAuthor a -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h", "--author", a] ""
      let l = lines out
      when (length l > 0) $ logDebug verbose $ "Found commit author " <> a
      pure l

