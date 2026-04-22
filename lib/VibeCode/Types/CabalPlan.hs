{-# OPTIONS_GHC -Wno-orphans #-}
{-# LANGUAGE ApplicativeDo         #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards       #-}

-- copy-paste of https://github.com/haskell-works/cabal-cache/blob/main/src/HaskellWorks/CabalCache/Types.hs
module VibeCode.Types.CabalPlan where

import Data.Aeson
import Data.Maybe
import Data.Text    (Text)
import GHC.Generics (Generic)
import Prelude      hiding (id)

import qualified Data.Aeson as J
import qualified Data.Text as T

type CompilerId   = Text
type PackageId    = Text
type PackageName  = Text
type URI          = Text

data PlanJson = PlanJson
  { compilerId  :: CompilerId
  , installPlan :: [Package]
  } deriving (Eq, Show, Generic)

data Package = Package
  { packageType   :: Text
  , id            :: PackageId
  , name          :: Text
  , version       :: Text
  , style         :: Maybe Text
  , pkgLoc        :: Maybe PackageLocation
  , componentName :: Maybe Text
  , components    :: Maybe Components
  , depends       :: [Text]
  , exeDepends    :: [Text]
  } deriving (Eq, Show, Generic)

data PackageLocation
  = LocalUnpackedPackage    FilePath
  | LocalTarballPackage     FilePath
  | RemoteTarballPackage    URI
  | RepoTarballPackage      Repo
  | RemoteSourceRepoPackage SourceRepoMaybe
  deriving (Eq, Show, Generic)

instance FromJSON PackageLocation where
  parseJSON = J.withObject "PackageLocation" $ \v -> do
    (String packageSrcType) <- v .: "type"
    case T.unpack packageSrcType of
      "local" -> do
        packageSrcPath  <- v .: "path"
        pure $ LocalUnpackedPackage packageSrcPath
      "local-tar" -> do
        packageSrcPath  <- v .: "path"
        pure $ LocalTarballPackage packageSrcPath
      "remote-tar" -> do
        packageSrcURI  <- v .: "uri"
        pure $ RemoteTarballPackage packageSrcURI
      "repo-tar" -> do
        packageSrcRepo  <- v .: "repo"
        pure $ RepoTarballPackage packageSrcRepo
      "source-repo" -> do
        packageSrcSourceRepo  <- v .: "source-repo"
        pure $ RemoteSourceRepoPackage packageSrcSourceRepo
      _ -> fail $ "Unknown source package location type: " <> T.unpack packageSrcType

data Repo
  = RepoLocalNoIndex FilePath
  | RepoRemote URI
  | RepoSecure URI
  deriving (Show, Eq, Ord, Generic)

instance FromJSON Repo where
  parseJSON = J.withObject "Repo" $ \v -> do
    (String repoType)  <- v .:  "type"
    case T.unpack repoType of
      "local-repo-no-index" -> do
        repoPath  <- v .: "path"
        pure $ RepoLocalNoIndex repoPath
      "remote-repo" -> do
        repoURI  <- v .: "uri"
        pure $ RepoRemote repoURI
      "secure-repo" -> do
        repoURI  <- v .: "uri"
        pure $ RepoSecure repoURI
      _ -> fail $ "Unknown repo type: " <> T.unpack repoType

data SourceRepoMaybe = SourceRepoMaybe
  { srpType :: String
  , srpLocation :: String
  , srpTag :: Maybe String
  , srpBranch :: Maybe String
  , srpSubdir :: Maybe FilePath
  , srpCommand :: [String]
  }
  deriving (Eq, Show, Generic)

instance FromJSON SourceRepoMaybe where
  parseJSON = J.withObject "SourceRepoMaybe" $ \v -> do
    srpType      <- v .:  "type"
    srpLocation  <- v .:  "location"
    srpTag       <- v .:? "tag"
    srpBranch    <- v .:? "branch"
    srpSubdir    <- v .:? "subdir"
    srpCommand   <- v .:? "command" .!= []
    pure $ SourceRepoMaybe {..}

newtype Components = Components
  { lib :: Maybe Lib
  } deriving (Eq, Show, Generic)

data Lib = Lib
  { depends    :: [Text]
  , exeDepends :: [Text]
  } deriving (Eq, Show, Generic)

newtype CompilerContext = CompilerContext
  { ghcPkgCmd :: [String]
  } deriving (Show, Eq, Generic)

instance FromJSON PlanJson where
  parseJSON = J.withObject "PlanJson" $ \v -> PlanJson
    <$> v .: "compiler-id"
    <*> v .: "install-plan"

instance FromJSON Package where
  parseJSON = J.withObject "Package" $ \v -> do
    packageType   <- v .:  "type"
    id            <- v .:  "id"
    name          <- v .:  "pkg-name"
    version       <- v .:  "pkg-version"
    style         <- v .:? "style"
    pkgLoc        <- v .:? "pkg-src"
    componentName <- v .:? "component-name"
    components    <- v .:? "components"
    depends       <- v .:? "depends"     .!= []
    exeDepends    <- v .:? "exe-depends" .!= []
    return Package {..}

instance FromJSON Components where
  parseJSON = J.withObject "Components" $ \v -> Components
    <$> v .:? "lib"

instance FromJSON Lib where
  parseJSON = J.withObject "Lib" $ \v -> Lib
    <$> v .:? "depends"     .!= []
    <*> v .:? "exe-depends" .!= []

