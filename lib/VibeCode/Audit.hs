{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE LambdaCase #-}

module VibeCode.Audit where

import VibeCode.CabalPlan
import VibeCode.Scan
import VibeCode.Types

import Control.Monad
import Data.List
import Data.Text     ( Text )

import qualified Data.Text as T

audit ::
     Maybe FilePath -- agents definition, if any
  -> FilePath
  -> Bool
  -> Bool
  -> Bool
  -> Bool
  -> Bool
  -> [Text]
  -> IO AuditResult
audit agentsDef buildDir verbose scanFiles scanHistory commitDetails keepDirectory exclude = do
  deps <- filter (\(pkg, _) -> pkg `notElem` exclude) <$> getDependencies buildDir verbose
  r <- forM (nub deps)
    $ \(pkg, ver) -> do
        scanHackagePackage
                agentsDef
                (T.unpack pkg <> "-" <> T.unpack ver)
                verbose
                scanFiles
                scanHistory
                commitDetails
                keepDirectory
  let auditResult = filter (\case
                             ScanResult{..} -> (not . null) scannedAgents
                             ScanResultError _ _ -> True
                           ) r

  pure $ AuditResult{..}
