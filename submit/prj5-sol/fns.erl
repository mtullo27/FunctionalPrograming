-module(fns).
-export([quadratic_roots/3, integral/4]).

% return roots of quadratic equation A*x^2 + B*x + C = 0.
quadratic_roots(A, B, C) ->
  T = B*B - 4*A*C,
  if T < 0 -> error;
     true ->
       Discr = math:sqrt(T),
       [ (-B + Discr)/(2 * A), (-B - Discr)/(2 * A) ]
  end.

% uses the trapezoidal rule to compute the definite integral
% of Fn over the range [From, To] using N steps.
integral(Fn, From, To, N) ->
  FFrom = Fn(From), FTo = Fn(To),
  BaseVal = (FFrom + FTo)/2,
  if (N =< 1) or (To < From) ->
       BaseVal;
     true ->
       Step = (To - From)/N,
       Pt1 = From + Step, 
       Sum = integral(Fn, Pt1, Step, To, 0),
       Integral = Step * (Sum + BaseVal),
       Integral
  end.

integral(Fn, ThisPt, Step, LastPt, Acc) ->
  if ThisPt >= LastPt -> Acc;
     true ->
       integral(Fn, ThisPt + Step, Step, LastPt, Acc + Fn(ThisPt))
  end.
  