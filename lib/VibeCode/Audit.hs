{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE LambdaCase #-}

module VibeCode.Audit where

import VibeCode.CabalPlan
import VibeCode.Logging
import VibeCode.Scan
import VibeCode.Types

import Control.Monad
import Data.List
import Data.Maybe
import Data.Text     ( Text )

import qualified Data.Text as T

audit ::
     FilePath
  -> Bool
  -> Bool
  -> Bool
  -> Bool
  -> [Text]
  -> IO AuditResult
audit buildDir verbose scanFiles scanHistory keeDirectory exclude = do
  deps <- filter (\(pkg, _) -> pkg `notElem` exclude) <$> getDependencies buildDir verbose
  r <- forM (nub deps)
    $ \(pkg, ver) -> do
        scanHackagePackage
                (T.unpack pkg <> "-" <> T.unpack ver)
                verbose
                scanFiles
                scanHistory
                keeDirectory
  let auditResult = filter (\case
                             ScanResult{..} -> (not . null) scannedAgents
                             ScanResultError _ _ -> True
                           ) r

  pure $ AuditResult{..}
