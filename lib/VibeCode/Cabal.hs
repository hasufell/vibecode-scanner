module VibeCode.Cabal where

import Control.Monad
import Data.List
import Distribution.PackageDescription.Parsec
import Distribution.Types.GenericPackageDescription
import Distribution.Types.PackageDescription
import Distribution.Types.PackageId
import Distribution.Types.PackageName
import Distribution.Types.Version                   hiding ( Version )

import qualified Data.ByteString as B

getCabalVersion :: FilePath -> IO (String, String)
getCabalVersion fp = do
  contents <- B.readFile fp
  gpd <- case parseGenericPackageDescriptionMaybe contents of
           Nothing -> fail $ "could not parse cabal file: " <> fp
           Just r  -> pure r
  let pkg =  package
           . packageDescription
           $ gpd
  let ver = intercalate "."
          . fmap show
          . versionNumbers
          . pkgVersion
          $ pkg
  let name = unPackageName
           . pkgName
           $ pkg
  pure (name, ver)
