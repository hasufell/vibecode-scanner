{-# OPTIONS_GHC -Wno-orphans #-}

module VibeCode.Types.JSON where

import VibeCode.Types

import Data.Aeson

import qualified Data.Text as T

instance ToJSON AuditResult where
    toJSON = genericToJSON defaultOptions

instance ToJSON ScanResult where
    toJSON = genericToJSON defaultOptions { sumEncoding = UntaggedValue }

instance ToJSON AgentResult where
    toJSON = genericToJSON defaultOptions { fieldLabelModifier = T.unpack . T.drop 2 . T.toLower . T.pack }

instance ToJSON Agent where
    toJSON = genericToJSON defaultOptions

instance FromJSON Agent

instance ToJSON GitNeedle where
    toJSON = genericToJSON defaultOptions

instance FromJSON GitNeedle

