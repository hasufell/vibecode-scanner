module VibeCode.Types.JSON where

import VibeCode.Types

import Data.Aeson
import GHC.Generics

instance ToJSON ScanResult where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON ScanResult

instance ToJSON AgentResult where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON AgentResult

instance ToJSON Agent where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON Agent

instance ToJSON GitNeedle where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON GitNeedle

