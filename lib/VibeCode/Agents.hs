{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module VibeCode.Agents where

import VibeCode.Types
import VibeCode.Types.Dhall
    ()

import Dhall
import Language.Haskell.TH.Syntax


-- inspired by https://github.com/VacTube/vibedetector/blob/main/main.go
defaultAgents :: [Agent]
defaultAgents = $(do
    let file = "agents/default.dhall"
    qAddDependentFile file
    v <- runIO $ inputFile @[Agent] auto file
    lift v
    )

getAgents :: Maybe FilePath -> IO [Agent]
getAgents Nothing  = pure defaultAgents
getAgents (Just f) = inputFile auto f
