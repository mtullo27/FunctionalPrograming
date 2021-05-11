-module(rand).

% the function started by spawn needs to be exported, else erlang
% seems to remove it.  It is easiest to simply export all functions.
-compile(export_all).

% Taken from Numerical Recipes;
% not recommended for real use because of poor randomness.
next_rand(X) ->
  M = 1 bsl 32,     %bit-shift-left
  A = 166325,
  C = 1013904223,
  (X*A + C) rem M.  %standard linear-congruential generator

% start rand server; next rand # generated will be next_rand(Seed).
start(Seed) -> 
	spawn(rand, rand_helper, [Seed]).

% stop rand server with PID ServerPid.
stop(ServerPid) -> ServerPid ! stop.

% return next random number from server at ServerPid
rand(ServerPid) -> 
	ServerPid ! {self()},
	receive
		{_, Result} -> Result
	end.
	
rand_helper(Seed) ->
	receive
		{ServerPid} ->
			Result = next_rand(Seed),
			ServerPid ! {self(), Result},
			rand_helper(Result);
		stop ->
			true
		end.


