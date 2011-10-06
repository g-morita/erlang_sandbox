-module(echo).
-export([start/0, print/1, stop/0, loop/0]).

start() ->
  register(pid_a, spawn(echo, loop, [])),
	ok.
	
print(Term) ->
 % stopと区別するためリストで送る
 pid_a ! [Term],
 ok.

stop() ->
 pid_a ! stop,
 ok.

loop() ->
  receive
	  [Term] ->
		  io:format("pid_a:~p~n", [Term]),
			loop();
		stop ->
		  ok
  end.
	
