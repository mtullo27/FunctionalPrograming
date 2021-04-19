/** The first few problems involve problems over trees where a Tree is
 *  either leaf(V) or tree(Tree, V, Tree) where value V is any
 *  non-variable prolog term.
 */

/** Exercise 1 Requirements: sum_tree(Tree, Sum) should succeed if
 *  Tree is a tree containing numeric values and Sum matches the sum
 *  of all the values in Tree. "15-points"
 */
%Edited Log:
%?- sum_tree(leaf(5), Sum).
%Sum = 5.
%?- sum_tree(tree(leaf(5), 3, tree(leaf(3), 2, leaf(4))), Sum).
%Sum = 17.

sum_tree(leaf(V), Sum):- Sum is V.

sum_tree(tree(L, V, R), Sum):-
	sum_tree(L, Sum1),
	sum_tree(R, Sum2),
	Sum is V+Sum1+Sum2.
	
sum_tree(Tree, Sum):- sum_tree(tree(L, V, R), S).

/** Exercise 2 Requirements: naive_flatten_tree(Tree, Flattened)
 *  should succeed if Tree is a tree and Flattened is a list
 *  containing all the values in Tree obtained using an in-order
 *  traversal.  The solution may not define any auxiliary procedures.
 *  "15-points"
 */
%Hints: Use built-in append/3.
%Edited Log:
%?- naive_flatten_tree(leaf(5), Flattened).
%Flattened = [5].
%?- naive_flatten_tree(tree(leaf(5), 3, tree(leaf(3), 2, leaf(4))), Flattened).
%Flattened = [5, 3, 3, 2, 4].
%?- naive_flatten_tree(tree(leaf(x), y, tree(leaf([a, b]), 2, leaf([c, z]))), Flattened).
%Flattened = [x, y, [a, b], 2, [c, z]].

naive_flatten_tree(leaf(V), Flattened):- Flattened = [V].

naive_flatten_tree(tree(L, V, R), Flattened):-
    naive_flatten_tree(L, Lsl),
    naive_flatten_tree(R, Lsr),
    append(Lsl, [V|Lsr], Flattened).

naive_flatten_tree(Tree, Flattened):- naive_flatten_tree(tree(L, V, R), F).

/** Exercise 3 Requirements: flatten_tree/2 has the same requirements
 *  as naive_flatten_tree/2.  However, it may use auxiliary procedures
 *  and must run in time linear in the size of Tree.  "20-points"
 */
%Hints: Define an auxiliary procedure with an accumulator.
%Use prolog built-in reverse/2.
%Edited Log:
%?- flatten_tree(tree(leaf(5), 3, tree(leaf(3), 2, leaf(4))), Flattened).
%Flattened = [5, 3, 3, 2, 4].
%?- flatten_tree(tree(leaf(x), y, tree(leaf([a, b]), 2, leaf([c, z]))),
%                Flattened).
%Flattened = [x, y, [a, b], 2, [c, z]].


% Exercise 4 Requirements: Write a Prolog procedure
% parse_arith(Tokens, AST) which will parse list Tokens into an AST.
% Specifically, the parser should parse the language defined by the
% following grammar:
%
% expr
%   : expr '+' term
%   | expr '-' term
%   | term
%   ;
%
% term
%   : term '*' factor
%   | term '/' factor
%   ;
%
% factor
%   : '-' factor
%   | '(' expr ')'
%   | INT        # INT satisfies Prolog's int(INT)
%   ;
%
% The parser should produce an AST as Prolog structures having the
% operators as functors; i.e. the AST for input tokens [1, +, 2] should
% be the Prolog term 1 + 2 (equivalent to +(1, 2)).  This will make
% it possible to run the AST through Prolog's is/2 to evaluate the
% expresseion. "25-points"
%
% Edited Log:
% ?- parse_arith([ 42 ], Ast), Val is Ast.
% Ast = Val, Val = 42.
% ?- parse_arith([ 1, +,  2, +, 3 ], Ast), Val is Ast.
%Ast = 1+2+3,
% Val = 6 ;
% false.
% paren don't make any diff in generated AST below
% ?- parse_arith([ '(', 1, +,  2, ')', +, 3 ], Ast), Val is Ast.
% Ast = 1+2+3,
% Val = 6 ;
% false.
% paren makes a diff in generated AST below
% ?- parse_arith([ 1, +,  '(', 2, +, 3, ')' ], Ast), Val is Ast.
% Ast = 1+(2+3),
% Val = 6 ;
% false.
% ?- parse_arith([ 1, -, 2, -, 3 ], Ast), Val is Ast.
% Ast = 1-2-3,
% Val = -4 ;
% false.
% since - is non-associative, paren not only gives different AST
% but evaluates to a different value.
% ?- parse_arith([ 1, -, '(', 2, -, 3, ')' ], Ast), Val is Ast.
% Ast = 1-(2-3),
% Val = 2 ;
% false.
% ?- parse_arith([ 3, *, '(', 2, -, -, 3, ')' ], Ast), Val is Ast.
% Ast = 3*(2- - 3),
% Val = 15 ;
% false.
% ?- parse_arith([ 3, *, 2, -, -, 3 ], Ast), Val is Ast.
% Ast = 3*2- - 3,
% Val = 9 ;
% false.
% erroneous input results in failure
% ?- parse_arith([ *, 3 ], Ast), Val is Ast.
%false.
%
% ?- parse_arith([ 3, ')' ], Ast), Val is Ast.
% false.
% ?- 

fact --> term

term --> expr

expr(X) --> num(A),
	[+],
	expr(B),
	X is A+B.
	
expr(X) --> num(A),
	[-],
	expr(B),
	X is A-B.

num(W) --> [W], 
	number(W).

% An NFA is represented as a Prolog structure nfa(S, Transitions, Finals)
% where S is the current NFA state, Finals is a list of final states and
% Transitions is a list of transitions where each transition is
% represented as a triple S1 - I - S2 representing a transition from
% state S1 to state S2 on input symbol I.  
  
% from <https://en.wikipedia.org/wiki/Nondeterministic_finite_automaton>
% states 0, 1, 2, 3 renamed to a, b, c, d to avoid confusion with 0, 1 inputs
% This NFA accepts inputs (0|1)* 1 (0|1)(0|1)(0|1)
wiki_nfa(nfa(x, [ x - 0 - x, x - 1 - x, x - 1 - a,
		  a - 0 - b, a - 1 - b,
		  b - 0 - c, b - 1 - c,
		  c - 0 - d, c - 1 - d
		], [d])).

% Exercise 5 Requirements: nfa_sim(NFA, Inputs, States) should succeed
% iff it is possible for NFA to transition on input symbols Inputs to
% some final state.  States should be match a trace of the states
% transited, starting with the initial state and ending with the
% final state; if there are n input symbols, then there should be
% n + 1 transited states. "25-points"

% Edited Log
% starts out with a transition from init state x back to state x
% ?- wiki_nfa(N), nfa_sim(N, [1, 1, 1, 0, 0], Ss).
% N = nfa(...),
% Ss = [x, x, a, b, c, d] ;
% false.
% starts out with a transition from init state x to state a
% ?- wiki_nfa(N), nfa_sim(N, [1, 1, 1, 0], Ss).
% N = nfa(...),
% Ss = [x, a, b, c, d] ;
% false.
% no solution if there are not at least 3 symbols after first 1
% ?- wiki_nfa(N), nfa_sim(N, [0, 1, 1, 0], Ss).
% false.
% no solution if there are not at least 3 symbols after first 1
% ?- wiki_nfa(N), nfa_sim(N, [1, 1, 1], Ss).
% false.

