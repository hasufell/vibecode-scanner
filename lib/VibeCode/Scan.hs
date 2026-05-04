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
     Maybe FilePath -- agents definition, if any
  -> String  -- ^ pkg name
  -> Bool    -- ^ verbose
  -> Bool    -- ^ scan files
  -> Bool    -- ^ scan history
  -> Bool    -- ^ show detailed commits
  -> Bool    -- ^ keep directories
  -> IO ScanResult
scanHackagePackage agentsDef resultPkg verbose scanFiles scanHistory commitDetails keepDirectory = fmap (either (ScanResultError resultPkg) (ScanResult resultPkg)) $
  withSystemTempDirectory "vibecode-scanner-bin" $ \bin -> withTmp keepDirectory $ \tmp -> runExceptT $ do
    let git = bin </> "git"
    origGit <- ExceptT $ maybe (Left "No git executable found") Right <$> liftIO (findExecutable "git")
    liftIO $ do
      writeFile git (gitScript origGit)
      setPermissions git (emptyPermissions { executable = True, readable = True, writable = True, searchable = True })
    newEnv <- liftIO $ addToPath [bin] False

    liftIO $ when keepDirectory $ logStderr $ "Working dir: " <> tmp
    liftIO $ logDebug verbose $ "Fetching " <> resultPkg
    ExceptT $ fmap (first (displayException @SomeException))
            $ try $ withCurrentDirectory tmp
            $ callCreateProcess (proc "cabal" ["get", "--verbose=0", "--source-repository=head", resultPkg]){ env = Just newEnv }

    (d:_) <- liftIO $ listDirectory tmp
    let cabal_dir = tmp </> d

    agents <- liftIO $ getAgents agentsDef
    catMaybes <$> liftIO (forM agents (scanAgent cabal_dir verbose scanFiles scanHistory commitDetails))
 where
  gitScript origGit =
    unlines [ "#!/bin/sh"
            , "exec " <> origGit <> " -c url.\"https://github.com/\".insteadOf=\"git://github.com/\" \"$@\""
            ]

scanRemoteRepo ::
     Maybe FilePath -- agents definition, if any
  -> String          -- ^ repository
  -> Maybe String    -- ^ branch
  -> Bool            -- ^ verbose
  -> Bool            -- ^ scan files
  -> Bool            -- ^ scan history
  -> Bool            -- ^ show detailed commits
  -> Bool            -- ^ keep directories
  -> IO ScanResult
scanRemoteRepo agentsDef repository branch verbose scanFiles scanHistory commitDetails keepDirectory =
  withTmp keepDirectory $ \tmp -> do
    when keepDirectory $ logStderr $ "Working dir: " <> tmp
    withCurrentDirectory tmp $
      callProcess "git" $
           ["-C", tmp, "clone"]
        <> maybe [] (\b -> ["-b", b, "--single-branch"]) branch
        <> [repository, "repo"]
    let cabal_dir = tmp </> "repo"
    scanLocalDir agentsDef cabal_dir verbose scanFiles scanHistory commitDetails

scanLocalDir ::
     Maybe FilePath -- agents definition, if any
  -> FilePath        -- ^ repository
  -> Bool            -- ^ verbose
  -> Bool            -- ^ scan files
  -> Bool            -- ^ scan history
  -> Bool            -- ^ show detailed commits
  -> IO ScanResult
scanLocalDir agentsDef cabal_dir verbose scanFiles scanHistory commitDetails = do
  r <- getDirectoryFiles cabal_dir ["*.cabal"]
  (pkg, ver) <- case r of
    (cabalFile:_) -> getCabalVersion (cabal_dir </> cabalFile)
    _ -> pure ("unknown", "unknown")

  let resultPkg = pkg <> "-" <> ver
  agents <- liftIO $ getAgents agentsDef
  resultAgent <- catMaybes <$> forM agents (scanAgent cabal_dir verbose scanFiles scanHistory commitDetails)

  pure $ ScanResult resultPkg resultAgent

withTmp :: Bool -> (FilePath -> IO a) -> IO a
withTmp keepDirectory action =
  if keepDirectory
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
  -> Bool      -- ^ show detailed commits
  -> Agent
  -> IO (Maybe AgentResult)
scanAgent dir verbose scanFiles scanHistory commitDetails Agent{..} = do
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

  commits <-
    if scanHistory
    then mconcat <$> forM aiGitNeedles (findGetNeedle dir verbose)
    else pure []

  let arCommits = length (nub commits)
  let arCommitDetails = if commitDetails then Just (nub commits) else Nothing

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
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h (%an): %s", "--grep", m] ""
      let l = lines out
      unless (null l) $ logDebug verbose $ "Found commit message " <> m
      pure l
    GitAuthor a -> do
      out <- readProcess "git" ["-C", dir, "log", "-i", "--format=%h (%an): %s", "--author", a] ""
      let l = lines out
      unless (null l) $ logDebug verbose $ "Found commit author " <> a
      pure l

