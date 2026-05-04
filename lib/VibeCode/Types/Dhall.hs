{-# OPTIONS_GHC -Wno-orphans #-}

module VibeCode.Types.Dhall where

import VibeCode.Types

import Dhall

import qualified Data.Text as T

instance FromDhall AuditResult where
  autoWith _ = genericAutoWith defaultInterpretOptions

instance FromDhall ScanResult where
  autoWith _ = genericAutoWith defaultInterpretOptions

instance FromDhall AgentResult where
  autoWith _ = genericAutoWith defaultInterpretOptions
    { fieldModifier = T.drop 2 . T.toLower }

instance FromDhall Agent where
  autoWith _ = genericAutoWith defaultInterpretOptions

instance FromDhall GitNeedle where
  autoWith _ = genericAutoWith defaultInterpretOptions

instance ToDhall AuditResult where
  injectWith _ = genericToDhallWith defaultInterpretOptions

instance ToDhall ScanResult where
  injectWith _ = genericToDhallWith defaultInterpretOptions

instance ToDhall AgentResult where
  injectWith _ = genericToDhallWith defaultInterpretOptions
    { fieldModifier = T.drop 2 . T.toLower }

instance ToDhall Agent where
  injectWith _ = genericToDhallWith defaultInterpretOptions

instance ToDhall GitNeedle where
  injectWith _ = genericToDhallWith defaultInterpretOptions

