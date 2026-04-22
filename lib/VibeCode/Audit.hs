{-# LANGUAGE RecordWildCards #-}

module VibeCode.Audit where

import VibeCode.CabalPlan
import VibeCode.Logging
import VibeCode.Scan
import VibeCode.Types

import Control.Monad
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
  auditResult <- fmap catMaybes $ forM deps
    $ \(pkg, ver) -> do
        r <- scanHackagePackage
                (T.unpack pkg <> "-" <> T.unpack ver)
                verbose
                scanFiles
                scanHistory
                keeDirectory
        case r of
          Left e -> do
            logStderr $ "Could not fetch package " <> T.unpack pkg <> "\nReason was: " <> e
            pure Nothing
          Right r' -> pure $ Just r'

  pure $ AuditResult{..}
  pure $ AuditResult{..}
