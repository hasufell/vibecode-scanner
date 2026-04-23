{-# LANGUAGE DeriveGeneric #-}

module VibeCode.Types where

import GHC.Generics

data ScanResult = ScanResult
  { scannedPkg :: String
  , scannedAgents :: [AgentResult]
  } |
  ScanResultError
  { scannedPkg :: String
  , scanError :: String
  }
  deriving (Eq, Generic, Show)

data AuditResult = AuditResult
  { auditResult :: [ScanResult]
  }
  deriving (Eq, Generic, Show)

data AgentResult = AgentResult
  { arName :: String
  , arFiles :: [FilePath]
  , arDirectories :: [FilePath]
  , arCommits :: Int
  , arCommitDetails :: Maybe [String]
  }
  deriving (Eq, Generic, Show)

data Agent = Agent
  { aiName :: String
  , aiUrl :: String
  , aiFiles :: [FilePath]
  , aiDirectories :: [FilePath]
  , aiGitNeedles :: [GitNeedle]
  }
  deriving (Eq, Generic, Show)

data GitNeedle
  = GitCommitMessage String
  | GitAuthor String
  deriving (Eq, Generic, Show)




