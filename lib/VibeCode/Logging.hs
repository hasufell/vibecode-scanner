module VibeCode.Logging where

import Control.Monad
import System.IO

logStderr :: String -> IO ()
logStderr str = do
  hPutStrLn stderr str

logDebug :: Bool -> String -> IO ()
logDebug verbose str =
  when verbose $ logStderr str
