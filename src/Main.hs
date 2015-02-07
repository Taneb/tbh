{-# LANGUAGE OverloadedStrings #-}
module Main where

import System.Directory
import System.Environment
import System.Exit
import System.FilePath
import System.IO

import Web.Scotty

-- | 'fileServer' takes a path to a directory and serves
--   the contents of that directory. HTML files have an appropriate
--   content type but no other guarantees of that sort are made.
--
--   Make sure you don't serve something you don't want to be public!
fileServer :: FilePath -> ScottyM ()
fileServer basePath = get (capture "/:filename") $ do
  fileName <- fmap (basePath </>) $ param "filename"
  file fileName
  case takeExtension fileName of
    ".html" -> setHeader "Content-Type" "text/html"
    _ -> return ()

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> do
      hPutStrLn stderr "Please supply a path to a directory"
      exitFailure
    (basePath:_) -> do
      cond <- doesDirectoryExist basePath
      if cond
        then do
        scotty 3000 $ fileServer basePath
        else do
        hPutStrLn stderr "That directory does not exist!"
        exitFailure
