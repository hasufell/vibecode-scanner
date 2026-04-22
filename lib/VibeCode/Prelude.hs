{-# LANGUAGE CPP #-}

module VibeCode.Prelude where

import Data.List          ( intercalate )
import System.Environment ( getEnvironment )
import System.FilePath

import qualified Data.Map.Strict as Map

#if defined(IS_WINDOWS)
isWindows, isNotWindows :: Bool
isWindows = True
isNotWindows = not isWindows
#else
isWindows, isNotWindows :: Bool
isWindows = False
isNotWindows = not isWindows
#endif

addToPath :: [FilePath]
          -> Bool         -- ^ if False will prepend
          -> IO [(String, String)]
addToPath paths append = do
 cEnv <- getEnvironment
 return $ addToPath' cEnv paths append

addToPath' :: [(String, String)]
          -> [FilePath]
          -> Bool         -- ^ if False will prepend
          -> [(String, String)]
addToPath' cEnv' newPaths append =
  let cEnv           = Map.fromList cEnv'
      paths          = ["PATH", "Path"]
      curPaths       = (\x -> maybe [] splitSearchPath (Map.lookup x cEnv)) =<< paths
      {- HLINT ignore "Redundant bracket" -}
      newPath        = intercalate [searchPathSeparator] (if append then (curPaths ++ newPaths) else (newPaths ++ curPaths))
      envWithoutPath = foldr Map.delete cEnv paths
      pathVar        = if isWindows then "Path" else "PATH"
      envWithNewPath = Map.toList $ Map.insert pathVar newPath envWithoutPath
  in envWithNewPath
