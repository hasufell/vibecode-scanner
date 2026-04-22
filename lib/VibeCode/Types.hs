{-# LANGUAGE DeriveGeneric #-}

module VibeCode.Types where

import GHC.Generics

data ScanResult = ScanResult {
    resultAgent :: [AgentResult]
  }
  deriving (Generic, Show, Eq)

data AgentResult = AgentResult {
    arName        :: String
  , arFiles       :: [FilePath]
  , arDirectories :: [FilePath]
  , arCommits     :: Int
  }
  deriving (Generic, Show, Eq)

data Agent = Agent {
    aiName        :: String
  , aiUrl         :: String
  , aiFiles       :: [FilePath]
  , aiDirectories :: [FilePath]
  , aiGitNeedles  :: [GitNeedle]
  }
  deriving (Generic, Show, Eq)

data GitNeedle = GitCommitMessage String
               | GitAuthor String
  deriving (Generic, Show, Eq)

