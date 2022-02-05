module Datas where


data Enviroment = Enviroment{ 
    corral::[(Int, Int)], 
    robots::[((Int,Int),Bool)],
    childrens::[((Int,Int), Bool)],
    obstacles::[(Int,Int)],
    dirts::[(Int,Int)]
    } 
    deriving (Show)

