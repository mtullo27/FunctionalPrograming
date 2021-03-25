quadratic_roots(A, B, C, Z):- D is B*B,
E is 4*A*C,
F is 2*A,
G is D-E,
H is sqrt(G),
P is -(B+H)/F,
R is (H-B)/F,
Z = [P, R].

quadratic_helper(B, Z, D):- 
P is [-(B+D)/F, (D-B)/F],
Z = P.

quadratic_roots2(A, B, C, Z):- D is B*B,
E is 4*A*C,
F is D-E,
G is sqrt(F),
R is quadratic_helper(B, Z, G),
Z = R.





