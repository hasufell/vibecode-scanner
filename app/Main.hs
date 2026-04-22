{-# LANGUAGE LambdaCase      #-}
{-# LANGUAGE RecordWildCards #-}

module Main where

import VibeCode.Types.JSON ()
import VibeCode.Scan (scanHackagePackage)

import Data.Aeson.Encode.Pretty
import Data.Maybe
import Options.Applicative

import qualified Data.Text.Lazy as T
import qualified Data.Text.Lazy.Encoding as TE

-- https://github.com/pcapriotti/optparse-applicative/issues/148

-- | A switch that can be enabled using --foo and disabled using --no-foo.
--
-- The option modifier is applied to only the option that is *not* enabled
-- by default. For example:
--
-- > invertableSwitch "recursive" True (help "do not recurse into directories")
--
-- This example makes --recursive enabled by default, so
-- the help is shown only for --no-recursive.
invertableSwitch
    :: String              -- ^ long option
    -> Maybe Char          -- ^ short option for the non-default option
    -> Bool                -- ^ is switch enabled by default?
    -> Mod FlagFields Bool -- ^ option modifier
    -> Parser (Maybe Bool)
invertableSwitch longopt shortopt defv optmod = invertableSwitch' longopt shortopt defv
    (if defv then mempty else optmod)
    (if defv then optmod else mempty)

-- | Allows providing option modifiers for both --foo and --no-foo.
invertableSwitch'
    :: String              -- ^ long option (eg "foo")
    -> Maybe Char          -- ^ short option for the non-default option
    -> Bool                -- ^ is switch enabled by default?
    -> Mod FlagFields Bool -- ^ option modifier for --foo
    -> Mod FlagFields Bool -- ^ option modifier for --no-foo
    -> Parser (Maybe Bool)
invertableSwitch' longopt shortopt defv enmod dismod = optional
    ( flag' True ( enmod <> long longopt <> if defv then mempty else maybe mempty short shortopt)
    <|> flag' False (dismod <> long nolongopt <> if defv then maybe mempty short shortopt else mempty)
    )
  where
    nolongopt = "no-" ++ longopt

data VibeCommand = Scan ScanOptions ScanTarget
                 | Audit AuditOptions

data ScanTarget = HackagePackage String
                | RemoteRepo String

data ScanOptions = ScanOptions {
    scanHistory  :: Maybe Bool
  , scanFiles    :: Maybe Bool
  , scanKeeDirectory :: Maybe Bool
  }

data AuditOptions = AuditOptions {
    auditHistory :: Maybe Bool
  , auditFiles   :: Maybe Bool
  , auditKeeDirectory :: Maybe Bool
  }

vibeCommandP :: Parser VibeCommand
vibeCommandP = hsubparser $
     command "scan"  (info (Scan <$> scanOptionsP <*> scanTargetP) (progDesc "Scan for LLM garbage"     ))
  <> command "audit" (info (Audit <$> auditOptionsP)               (progDesc "Audit the current project"))

auditOptionsP :: Parser AuditOptions
auditOptionsP = AuditOptions
  <$> invertableSwitch "history"          Nothing True  (help "Scan the git history")
  <*> invertableSwitch "files"            Nothing True  (help "Scan for agent files")
  <*> invertableSwitch "keep-directories" Nothing False (help "Keep temporary directories")

scanOptionsP :: Parser ScanOptions
scanOptionsP = ScanOptions
  <$> invertableSwitch "history"          Nothing True  (help "Scan the git history")
  <*> invertableSwitch "files"            Nothing True  (help "Scan for agent files")
  <*> invertableSwitch "keep-directories" Nothing False (help "Keep temporary directories")

scanTargetP :: Parser ScanTarget
scanTargetP = hsubparser $
     command "hackage"    (HackagePackage <$> info (argument str (metavar "PACKAGE"   )) (progDesc "Scan a hackage package"  ))
  <> command "repository" (RemoteRepo     <$> info (argument str (metavar "REPOSITORY")) (progDesc "Scan a retome repository"))


main :: IO ()
main =
  execParser opts >>= \case
    (Scan ScanOptions{..} (HackagePackage pkg )) -> do
      res <- scanHackagePackage pkg (fromMaybe True scanFiles) (fromMaybe True scanHistory) (fromMaybe False scanKeeDirectory)
      let bs = encodePretty res
      putStrLn (T.unpack (TE.decodeUtf8 bs))
    (Scan ScanOptions{..} (RemoteRepo     repo)) -> do
      putStrLn $ "Scan " <> repo
 where
  opts = info (vibeCommandP <**> helper)
              (fullDesc
              <> progDesc "The ultimate vibecode scanner"
              )
