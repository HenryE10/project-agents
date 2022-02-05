module Main where

import Lib
import Enviroment
import System.Random

main :: IO ()
main = do 
    gen1 <- newStdGen
    gen2 <- newStdGen
    print (testEnv4 5 5 25 5 4 2 3 gen1 gen2)
