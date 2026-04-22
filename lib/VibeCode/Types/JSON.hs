{-# OPTIONS_GHC -Wno-orphans #-}

module VibeCode.Types.JSON where

import VibeCode.Types

import Data.Aeson

instance ToJSON AuditResult where
    toEncoding = genericToEncoding defaultOptions

instance FromJSON AuditResult

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

