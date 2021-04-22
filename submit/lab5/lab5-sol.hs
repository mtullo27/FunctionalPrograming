add n1 n2 = n1 + n2

plus = (+)

conc ls1 ls2 = ls1 ++ ls2

add10 = add 10

plus5 = plus 5

concHello = conc "hello"

first (v, _) = v

second (_, v) = v

fst3 (v, _, _) = v

snd3 (_, v, _) = v

sumFirst2 (x:y:z) = x + y

fnFirst2 [x, y] f1 f2 = f1 x y

fnFirst2 (x:y:z) f1 f2 = f2 x y

cartesianProduct ls1 ls2 = [ (x,y) | x <- ls1, y <- ls2 ]

cartesianProductIf ls1 ls2 predicate = [ (x,y) | x <- ls1, y <- ls2, predicate x y ]

pairs = [ (x, 3*x^2 + 2*x + 1) | x <-[1 .. 10]]

pairs2 = [ (x, 3*x^2 + 2*x + 1) | x <-[1 .. 10], (3*x^2 + 2*x + 1) `rem` 3 == 0]

oddEvenPairs n = [(x, y) | x <- [1 .. n], y <- [1 .. n], odd x, even y]

mapPair = map (\x -> (x, 3*x^2 + 2*x + 1)) [1 .. 10]

mapPair2 = filter (\(x, y) -> y `rem` 3==0) (map (\x -> (x, 3*x^2 + 2*x + 1)) [1 .. 10])

