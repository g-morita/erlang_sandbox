-module(echo).
-export([start/0, print/1, stop/0, loop/0]).

start() ->
  Pid = spawn_link(echo, loop, []),
  register(pid_a, Pid),
	ok.
	
print(Term) ->
 % stopと区別するためリストで送る
 pid_a ! [Term],
 ok.

stop() ->
 exit(pid_a),
 ok.

loop() ->
  receive
	  [Term] ->
		  io:format("pid_a:~p~n", [Term]),
			loop()
  end.

