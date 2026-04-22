{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

-- copy-paste of https://github.com/haskell-works/cabal-cache/blob/main/src/HaskellWorks/CabalCache/Topology.hs
module VibeCode.CabalPlan where

import VibeCode.Logging
import VibeCode.Types.CabalPlan

import Data.Aeson
import Data.List
import Data.Text                 ( Text )
import System.FilePath

import qualified Data.ByteString.Lazy as LBS


loadPlan ::
     FilePath    -- ^ build path
  -> IO PlanJson
loadPlan buildPath = do
  lbs <- LBS.readFile (buildPath </> "cache" </> "plan.json")
  either (fail . show) pure (eitherDecode lbs)

getDependencies ::
     FilePath    -- ^ build path
  -> Bool
  -> IO [(Text, Text)] -- ^ of the form <pkgid>-<pkgver>
getDependencies buildPath verbose = do
  plan <- loadPlan buildPath
  let (matches, ignored) = partition pkgFilter (installPlan plan)

  logDebug verbose $ "Matches: \n"
                     <> show (pkgName <$> matches)

  logDebug verbose $ "Could not figure out how to inspect the following packages: \n"
                     <> show (pkgName <$> ignored)

  pure (pkgTuple <$> matches)
 where
  pkgTuple Package{..} = (name, version)
  pkgName Package{..} = name <> "-" <> version
  pkgFilter Package{..}
    | Just "global" <- style
    , Just (RepoTarballPackage (RepoSecure uri)) <- pkgLoc
    , uri == "http://hackage.haskell.org/"
    = True
    | otherwise
    = False
