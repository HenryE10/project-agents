module Enviroment where


import System.Random
import Datas


directions_with_diagonals :: [(Int, Int)]
directions_with_diagonals = [(0, 1), (1, 0), (-1, 0), (0, -1),(1, -1), (-1, 1), (1, 1), (-1, -1)]

directions_without_diagonals :: [(Int, Int)]
directions_without_diagonals = [(0, 1), (1, 0), (-1, 0), (0, -1)]


isContain :: (Eq a) => [a] -> a -> Bool
isContain [] _ = False
isContain (x : xs) value = (x == value) || isContain xs value

isContain2 :: [((Int,Int),Bool)] -> (Int,Int) -> Bool
isContain2 [] _ = False
isContain2 (((i,j),b) : xs) (x,y) = ((x == i) && (j==y)) || isContain2 xs (x,y)

remove :: (Eq a) => [a] -> a -> [a]
remove [] _ = []
remove (x : xs) element = if x == element then xs else x : remove xs element

isValidPos :: (Int, Int) -> Int -> Int -> Bool
isValidPos (x, y) n m = x < n && y < m && x >= 0 && y >= 0

adyacentes_with_diagonals :: (Int, Int) -> [(Int, Int)]
adyacentes_with_diagonals (x, y) = [(x + dx, y + dy) | (dx, dy) <- directions_with_diagonals]

adyacentes_without_diagonals :: (Int, Int) -> [(Int, Int)]
adyacentes_without_diagonals (x, y) = [(x + dx, y + dy) | (dx, dy) <- directions_without_diagonals]

ramdom_list :: Int -> StdGen -> [Int]
ramdom_list d = randomRs (0, d)

--revisa si el ambiente en esa posicion esta vacio
isEmpty :: Enviroment -> (Int, Int) -> Bool
isEmpty env pos = not(isObstacle env pos || isChildren env pos || isRobot env pos || isCorral env pos || isDirt env pos) 

--revisa si el ambiente en esa posicion tiene un obstaculo
isObstacle :: Enviroment -> (Int, Int) -> Bool
isObstacle Enviroment{obstacles = o} pos = isContain o pos  

--revisa si el ambiente en esa posicion tiene un niño
isChildren :: Enviroment -> (Int, Int) -> Bool
isChildren Enviroment{childrens = ch} pos = isContain2 ch pos

--revisa si el ambiente en esa posicion tiene un Robot
isRobot :: Enviroment -> (Int, Int) -> Bool
isRobot Enviroment{robots = r} pos = isContain2 r pos

--revisa si el ambiente en esa posicion tiene un Corral
isCorral :: Enviroment -> (Int, Int) -> Bool
isCorral Enviroment{corral = c} pos = isContain c pos

isDirt :: Enviroment -> (Int, Int) -> Bool
isDirt Enviroment{dirts = d} pos = isContain d pos

--generar el corral
generate_corral:: Int -> Int -> Int -> (Int,Int) -> Enviroment
generate_corral n m d pos = 
    let c = create_corral n m d [pos] []
    in  Enviroment{corral = c, robots = [], childrens = [], obstacles = [], dirts = []}

--crear el corral
create_corral :: Int -> Int -> Int -> [(Int,Int)] -> [(Int, Int)] -> [(Int,Int)]
create_corral _ _ _ [] visit = visit
create_corral _ _ 0 _ visit = visit
create_corral n m d (a:r) visit = if isContain visit a || not (isValidPos a n m) then create_corral n m d r visit else create_corral n m (d-1) (r ++ adyacentes_with_diagonals a ) (a:visit)


--generar los niños
generate_childrens :: Enviroment -> [Int] -> [Int] -> Int -> Enviroment
generate_childrens env x y 0 = env
generate_childrens env _ [] _ = env
generate_childrens env [] _ _ = env
generate_childrens env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} (x1:xs) (y1:ys) c =
    if isEmpty env (x1,y1)
        then generate_childrens Enviroment{corral = corral, robots = r, childrens = (((x1,y1),False):ch), obstacles = o, dirts = d} xs ys (c-1)
        else generate_childrens env xs ys c

--generar los robots
generate_robots :: Enviroment -> [Int] -> [Int] -> Int -> Enviroment
generate_robots env x y 0 = env
generate_robots env _ [] _ = env
generate_robots env [] _ _ = env
generate_robots env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} (x1:xs) (y1:ys) c =
    if isEmpty env (x1,y1)
        then generate_robots Enviroment{corral = corral, robots = (((x1,y1),False):r), childrens = ch, obstacles = o, dirts = d} xs ys (c-1)
        else generate_robots env xs ys c

--generar los obstaculos
generate_obstacles :: Enviroment -> [Int] -> [Int] -> Int -> Enviroment
generate_obstacles env x y 0 = env
generate_obstacles env _ [] _ = env
generate_obstacles env [] _ _ = env
generate_obstacles env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} (x1:xs) (y1:ys) c =
    if isEmpty env (x1,y1)
        then generate_obstacles Enviroment{corral = corral, robots = r, childrens = ch, obstacles = ((x1,y1):o), dirts = d} xs ys (c-1)
        else generate_obstacles env xs ys c

--generar las suciedades
generate_dirts :: Enviroment -> [Int] -> [Int] -> Int -> Enviroment
generate_dirts env x y 0 = env
generate_dirts env _ [] _ = env
generate_dirts env [] _ _ = env
generate_dirts env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} (x1:xs) (y1:ys) c =
    if isEmpty env (x1,y1)
        then generate_dirts Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = ((x1,y1):d)} xs ys (c-1)
        else generate_dirts env xs ys c

--generar ambiente inicial
generate_Enviroment :: Int -> Int -> Int -> Int -> Int -> Int -> StdGen -> StdGen -> Enviroment
generate_Enviroment n m cant_Ch cant_O cant_D cant_R  gen1 gen2 =
  let xs = ramdom_list (n -1) gen1
      ys = ramdom_list (m -1) gen2
      corral = generate_corral n m cant_Ch (head xs, head ys) 
      childrens = generate_childrens corral xs ys cant_Ch
      robots = generate_robots childrens xs ys cant_R
      obstacles = generate_obstacles robots xs ys cant_O
   in generate_dirts obstacles xs ys cant_D




update_valid_mov_ch_and_r :: [((Int, Int),Bool)] -> (Int, Int) -> (Int, Int) -> [((Int, Int),Bool)]
update_valid_mov_ch_and_r [] _ _ = []
update_valid_mov_ch_and_r ((x,xr) : xs) pos1 pos2 = if pos1 == x then ((pos2,xr) : xs) else (x,xr):update_valid_mov_ch_and_r xs pos1 pos2

--selecciona aleatoriamente los niños que se van a mover si es posible con 50% de probabilidad de moverse {0,1,2,3} se mueve a esa posicion y {4,5,6,7} no se mueve
select_mov_children :: Int -> StdGen -> [Int]
select_mov_children c gen = take c (ramdom_list 7 gen)

mov_childrens :: Enviroment -> Int -> Int -> [Int] ->[((Int,Int),Bool)]-> StdGen ->Enviroment
mov_childrens enviroment _ _ _ [] _ = enviroment
mov_childrens enviroment _ _ [] _ _ = enviroment
mov_childrens enviroment n m (x:xs) (((i,j),k):r) gen =
    if not(x == 4 || x == 5 || x ==6 || x == 7 || k) 
        then mov_childrens (mov_children enviroment x (i,j) n m gen) n m xs r gen
        else mov_childrens enviroment m n xs r gen

mov_children :: Enviroment -> Int ->(Int, Int) -> Int -> Int -> StdGen -> Enviroment
mov_children env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} dir pos n m gen =
    if isEmpty env (adyacentes_without_diagonals pos !! dir) && isValidPos (adyacentes_without_diagonals pos !! dir) n m
        then Enviroment{corral = corral, robots = r, childrens = (update_children env pos (adyacentes_without_diagonals pos !! dir)), obstacles = o, dirts = d ++ (generate_dirts_childrens env n m pos gen) }
        else mov_obstacles_is_possible env n m pos dir gen
        

update_children :: Enviroment -> (Int, Int) -> (Int, Int) -> [((Int, Int), Bool)]
update_children env@Enviroment {childrens = ch, obstacles = o} pos1 pos2 =
  if not (isEmpty env pos2) && not (isObstacle env pos2)
    then ch
    else (update_valid_mov_ch_and_r ch pos1 pos2)



--selecciona dada una posición de un niño y la dirección a moverse todos los obstaculos que se encuentran seguidos.
selec_obstacles_continue :: Enviroment -> Int -> Int -> (Int, Int) -> Int -> [(Int, Int)]
selec_obstacles_continue env@Enviroment {obstacles = o} n m pos dir = if isValidPos ady n m && not (isEmpty env ady) && isObstacle env ady then (pos : (selec_obstacles_continue env n m pos dir)) else [pos]
  where
    ady = adyacentes_without_diagonals pos !! dir


--mueve todos los obstaculos que empuja un niño si es posible
mov_obstacles_is_possible:: Enviroment -> Int -> Int -> (Int,Int) -> Int -> StdGen -> Enviroment
mov_obstacles_is_possible env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m pos dir gen = if (isValidPos end_pos n m) && (isEmpty env end_pos) then Enviroment {corral = corral, robots = r, childrens = (update_children env pos obs_ady), obstacles = new_pos_obstacles, dirts = d ++ (generate_dirts_childrens env n m pos gen)} else env
    where
        obs_ady = adyacentes_without_diagonals pos !! dir
        obs_continue = selec_obstacles_continue env n m obs_ady dir
        end_pos = adyacentes_without_diagonals (obs_continue !! ((length obs_continue)-1)) !! dir 
        new_pos_obstacles = mov_obstacles o obs_continue dir

mov_obstacles :: [(Int, Int)] -> [(Int, Int)] -> Int -> [(Int, Int)]
mov_obstacles obs [] _ = obs
mov_obstacles [] _ _ = []
mov_obstacles (x : xs) pos dir = if isContain pos x then adyacentes_without_diagonals x !! dir : mov_obstacles xs pos dir else x : mov_obstacles xs pos dir




--genera la suciedad cuando se mueve un niño
generate_dirts_childrens ::Enviroment -> Int -> Int -> (Int, Int) -> StdGen -> [(Int,Int)]
generate_dirts_childrens env@Enviroment{corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m pos gen =
    let cuad = [x | x <- adyacentes_with_diagonals pos, isValidPos x n m, isEmpty env x]
        chs = [z | z <- adyacentes_with_diagonals pos, isValidPos z n m, isChildren env z, not(isCorral env z)]
        cant_dirt = cant_dirt_generate (length chs) gen
    in dirty cuad cant_dirt 


dirty:: [(Int,Int)] -> Int  -> [(Int,Int)]
dirty [] _  = []
dirty _ 0 = []
dirty (x:xs) cant_dirt  = x : dirty xs (cant_dirt -1)


cant_dirt_generate :: Int -> StdGen -> Int
cant_dirt_generate cant gen
  | cant == 1 = head (ramdom_list 1 gen)
  | cant == 2 = head (ramdom_list 2 gen)
  | otherwise = head (ramdom_list 6 gen)


clean_dirt::Enviroment -> (Int, Int) -> [(Int,Int)]
clean_dirt env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} pos =
  let suc = remove d pos
   in suc


cary_children:: Enviroment -> (Int, Int) -> Enviroment
cary_children env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} pos = 
    let robot = update_bool r pos True
        children = update_bool ch pos True
    in Enviroment {corral = corral, robots = robot, childrens = children, obstacles = o, dirts = d}

down_children:: Enviroment -> (Int, Int) -> Enviroment
down_children env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} pos = 
    let robot = update_bool r pos False
        children = update_bool ch pos False
    in Enviroment {corral = corral, robots = robot, childrens = children, obstacles = o, dirts = d}

update_bool:: [((Int,Int), Bool)] -> (Int,Int) -> Bool -> [((Int,Int), Bool)]
update_bool [] _ _ = [] 
update_bool ((x,k):xs) pos b = if x == pos then (x,b) : xs else ((x,k) : (update_bool xs pos b))


bfs_find_children :: Enviroment -> Int -> Int -> (Int,Int) ->[(Int,Int)] -> Int
bfs_find_children env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m (x,y) visit = 
    if isChildren env (x,y) &&  not(isCorral env (x,y) || isRobot env (x,y))   then 0 else if isObstacle env (x,y) || isRobot env (x,y) || not(isValidPos (x,y) n m) || isContain visit (x,y)|| (isChildren env (x,y) &&  isCorral env (x,y)) then -1 else 
       (mymin((bfs_find_children env n m (x-1,y) ((x,y):visit)): (bfs_find_children env n m (x+1,y) ((x,y):visit)):(bfs_find_children env n m (x,y-1) ((x,y):visit)):(bfs_find_children env n m (x,y+1) ((x,y):visit)):[]) +1)

bfs_find_dirt :: Enviroment -> Int -> Int -> (Int,Int) ->[(Int,Int)] -> Int
bfs_find_dirt env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m (x,y) visit = 
    if isDirt env (x,y)   then 0 else if isObstacle env (x,y) || isRobot env (x,y) || not(isValidPos (x,y) n m) || isContain visit (x,y)|| (isChildren env (x,y) &&  isCorral env (x,y)) then -1 else 
       (mymin((bfs_find_dirt env n m (x-1,y) ((x,y):visit)): (bfs_find_dirt env n m (x+1,y) ((x,y):visit)):(bfs_find_dirt env n m (x,y-1) ((x,y):visit)):(bfs_find_dirt env n m (x,y+1) ((x,y):visit)):[]) +1)

bfs_find_corral :: Enviroment -> Int -> Int -> (Int,Int) ->[(Int,Int)]->(Int,Int) -> Int
bfs_find_corral env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m (x,y) visit (i,j) = 
    if (x,y) == (i,j)   then 0 else if isObstacle env (x,y) || isRobot env (x,y) || not(isValidPos (x,y) n m) || isContain visit (x,y) || (isChildren env (x,y) &&  isCorral env (x,y)) then -1 else 
       (mymin((bfs_find_corral env n m (x-1,y) ((x,y):visit) (i,j)): (bfs_find_corral env n m (x+1,y) ((x,y):visit) (i,j)):(bfs_find_corral env n m (x,y-1) ((x,y):visit) (i,j)):(bfs_find_corral env n m (x,y+1) ((x,y):visit) (i,j)):[]) +1)

selec_mov_corral :: Enviroment -> Int -> Int -> Int -> (Int,Int) -> (Int,Int)
selec_mov_corral env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m c (x,y) =
    if (length corral - c) == -1 then (-1,-1) else
        let
            (i,j) = corral !! ((length corral) - c)
            ((pa,pb),pc)= minx(((x-1,y),(bfs_find_corral env n m (x-1,y) ((x,y):[]) (i,j))): ((x+1,y),(bfs_find_corral env n m (x+1,y) ((x,y):[]) (i,j))):((x,y-1),(bfs_find_corral env n m (x,y-1) ((x,y):[]) (i,j))):((x,y+1),(bfs_find_corral env n m (x,y+1) ((x,y):[]) (i,j))):[])
        in 
            if (x,y)==(i,j) then (x,y) else if isRobot env (corral !! ((length corral)-c)) || isChildren env (corral !! ((length corral) - c)) || pc == -1 then selec_mov_corral env n m (c+1) (x,y) else (pa,pb)

mov_robot1:: Enviroment ->Int -> Int -> Int -> Enviroment
mov_robot1 env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m cant =
    if cant == length r then env else
        let
            ((x,y),z) = r !! cant
            (i,j)=selec_mov_corral env n m 1 (x,y)
        in
            if (z == True)&&((x,y)==(i,j)) then mov_robot1 (down_children env (x,y)) n m (cant+1) else
                if (z == True) then mov_robot1 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (i,j), childrens = update_valid_mov_ch_and_r ch (x,y) (i,j), obstacles = o, dirts = d} n m (cant+1) else
                    if isChildren env (x,y) then mov_robot1 (cary_children env (x,y)) n m (cant+1) else 
                        let
                            ((ni,nj),nc)= minx(((x-1,y),(bfs_find_children env n m (x-1,y) ((x,y):[]))): ((x+1,y),(bfs_find_children env n m (x+1,y) ((x,y):[]))):((x,y-1),(bfs_find_children env n m (x,y-1) ((x,y):[]))):((x,y+1),(bfs_find_children env n m (x,y+1) ((x,y):[]))):[])
                        in
                            if nc == -1 then 
                                let
                                    ((di,dj),dc)= minx(((x-1,y),(bfs_find_dirt env n m (x-1,y) ((x,y):[]))): ((x+1,y),(bfs_find_dirt env n m (x+1,y) ((x,y):[]))):((x,y-1),(bfs_find_dirt env n m (x,y-1) ((x,y):[]))):((x,y+1),(bfs_find_dirt env n m (x,y+1) ((x,y):[]))):[])
                                in 
                                    if dc == -1 then mov_robot1 env n m (cant+1) else 
                                        mov_robot1 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (di,dj) , childrens = ch, obstacles = o, dirts = clean_dirt env (di,dj)} n m (cant+1)
                            else
                                mov_robot1 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (ni,nj) , childrens = ch, obstacles = o, dirts = clean_dirt env (ni,nj)} n m (cant+1)


mov_robot2:: Enviroment ->Int -> Int -> Int -> Enviroment
mov_robot2 env@Enviroment {corral = corral, robots = r, childrens = ch, obstacles = o, dirts = d} n m cant =
    if cant == length r then env else
        let
            ((x,y),z) = r !! cant
            (i,j)=selec_mov_corral env n m 1 (x,y)
        in
            if (z == True)&&((x,y)==(i,j)) then mov_robot2 (down_children env (x,y)) n m (cant+1) else
                if (z == True) then mov_robot2 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (i,j), childrens = update_valid_mov_ch_and_r ch (x,y) (i,j), obstacles = o, dirts = d} n m (cant+1) else
                     if isChildren env (x,y) then mov_robot2 (cary_children env (x,y)) n m (cant+1) else
                        let
                            ((di,dj),dc)= minx(((x-1,y),(bfs_find_dirt env n m (x-1,y) ((x,y):[]))): ((x+1,y),(bfs_find_dirt env n m (x+1,y) ((x,y):[]))):((x,y-1),(bfs_find_dirt env n m (x,y-1) ((x,y):[]))):((x,y+1),(bfs_find_dirt env n m (x,y+1) ((x,y):[]))):[])
                        in     
                            if dc == -1 then
                                let
                                    ((ni,nj),nc)= minx(((x-1,y),(bfs_find_children env n m (x-1,y) ((x,y):[]))): ((x+1,y),(bfs_find_children env n m (x+1,y) ((x,y):[]))):((x,y-1),(bfs_find_children env n m (x,y-1) ((x,y):[]))):((x,y+1),(bfs_find_children env n m (x,y+1) ((x,y):[]))):[])
                                in   
                                    if nc == -1 then mov_robot1 env n m (cant+1) else 
                                        mov_robot2 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (ni,nj) , childrens = ch, obstacles = o, dirts = clean_dirt env (ni,nj)} n m (cant+1)               
                            else
                                mov_robot2 Enviroment{corral = corral, robots = update_valid_mov_ch_and_r r (x,y) (di,dj) , childrens = ch, obstacles = o, dirts = clean_dirt env (di,dj)} n m (cant+1)



mymin::[Int] -> Int
mymin [] = -1
mymin (x:xs) = if x==(-1) then mymin xs else minmin x (mymin xs) 

minmin :: Int -> Int -> Int
minmin a b = if b == -1 then a else if a == -1 then b else min a b 

minx :: [((Int,Int),Int)] -> ((Int,Int),Int)
minx []=((-1,-1),-1)
minx ((a,b):xs) = if b == -1 then minx xs else minminx (a,b) (minx xs)

minminx :: ((Int,Int),Int) -> ((Int,Int),Int) -> ((Int,Int),Int)
minminx (a,b) (x,y) = if b== -1 then (x,y) else if y == -1 then (a,b) else if b>y then (x,y) else (a,b)

run_simulate :: Enviroment -> Int -> Int -> Int -> Int -> StdGen -> StdGen -> Enviroment
run_simulate env@Enviroment {corral = corral, robots = rob, childrens = chil, obstacles = obs, dirts = dir} n m t temp gen1 gen2=
    if(temp == 0) then  env
    else
        let s = select_mov_children (length chil) gen1
        in
           run_simulate (mov_childrens (mov_robot1 env n m 0) n m s chil gen2) n m t (temp-1) gen1 gen2
        


testEnv4:: Int -> Int -> Int -> Int -> Int -> Int-> Int -> StdGen -> StdGen -> Enviroment
testEnv4 n m t ch r o d gen1 gen2 =run_simulate (generate_Enviroment n m ch o d r gen1 gen2) n m t t gen1 gen2
        

testEnv5:: Int -> Int -> Int -> Int -> Int -> Int-> Int -> StdGen -> StdGen -> Int
testEnv5 n m t ch r o d gen1 gen2 = let
    env = generate_Enviroment n m ch o d r gen1 gen2
    in bfs_find_children env n m (0,0) []