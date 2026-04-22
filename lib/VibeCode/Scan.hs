{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

module VibeCode.Scan where

import VibeCode.Agents
import VibeCode.Cabal
import VibeCode.Logging
import VibeCode.Prelude
import VibeCode.Types

import Control.Exception.Safe       ( SomeException, displayException, try )
import Control.Monad
import Control.Monad.Except
import Control.Monad.IO.Class       ( liftIO )
import Data.Bifunctor               ( first )
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
scanHackagePackage resultPkg verbose scanFiles scanHistory keeDirectory = fmap (either (ScanResultError resultPkg) (ScanResult resultPkg)) $
  withSystemTempDirectory "vibecode-scanner-bin" $ \bin -> withTmp keeDirectory $ \tmp -> runExceptT $ do
    let git = bin </> "git"
    origGit <- ExceptT $ maybe (Left "No git executable found") Right <$> liftIO (findExecutable "git")
    liftIO $ do
      writeFile git (gitScript origGit)
      setPermissions git (emptyPermissions { executable = True, readable = True, writable = True, searchable = True })
    newEnv <- liftIO $ addToPath [bin] False

    liftIO $ when keeDirectory $ logStderr $ "Working dir: " <> tmp
    liftIO $ logDebug verbose $ "Fetching " <> resultPkg
    ExceptT $ fmap (first (displayException @SomeException))
            $ try $ withCurrentDirectory tmp
            $ callCreateProcess (proc "cabal" ["get", "--verbose=0", "--source-repository=head", resultPkg]){ env = Just newEnv }

    (d:_) <- liftIO $ listDirectory tmp
    let cabal_dir = tmp </> d

    catMaybes <$> liftIO (forM agents (scanAgent cabal_dir verbose scanFiles scanHistory))
 where
  gitScript origGit =
    unlines [ "#!/bin/sh"
            , "exec " <> origGit <> " -c url.\"https://github.com/\".insteadOf=\"git://github.com/\" \"$@\""
            ]

scanRemoteRepo ::
     String          -- ^ repository
  -> Maybe String    -- ^ branch
  -> Bool            -- ^ verbose
  -> Bool            -- ^ scan files
  -> Bool            -- ^ scan history
  -> Bool            -- ^ keep directories
  -> IO ScanResult
scanRemoteRepo repository branch verbose scanFiles scanHistory keeDirectory =
  withTmp keeDirectory $ \tmp -> do
    when keeDirectory $ logStderr $ "Working dir: " <> tmp
    withCurrentDirectory tmp $
      callProcess "git" $
           ["-C", tmp, "clone"]
        <> maybe [] (\b -> ["-b", b, "--single-branch"]) branch
        <> [repository, "repo"]
    let cabal_dir = tmp </> "repo"

    (cabalFile:_) <- getDirectoryFiles cabal_dir ["*.cabal"]

    (pkg, ver) <- getCabalVersion (cabal_dir </> cabalFile)
    let resultPkg = pkg <> "-" <> ver
    resultAgent <- catMaybes <$> forM agents (scanAgent cabal_dir verbose scanFiles scanHistory)

    pure $ ScanResult resultPkg resultAgent

withTmp :: Bool -> (FilePath -> IO a) -> IO a
withTmp keeDirectory action =
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
      unless (null l) $ logDebug verbose $ "Found commit message " <> m
      pure l
    GitAuthor a -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h", "--author", a] ""
      let l = lines out
      unless (null l) $ logDebug verbose $ "Found commit author " <> a
      pure l

