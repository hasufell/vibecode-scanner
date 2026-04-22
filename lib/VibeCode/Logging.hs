module VibeCode.Logging where

import System.IO

logStderr :: String -> IO ()
logStderr str = do
  hPutStrLn stderr str
