-module(my_supervisor).
-export([start_link/2, stop/1]).
-export([init/1]).

start_link(Name, ChildSpecList) ->
  register(Name, spawn_link(my_supervisor, init, [ChildSpecList])), ok.

init(ChildSpecList) ->
  process_flag(trap_exit, true),
	loop(start_children(ChildSpecList)).

start_children([]) -> [];
% 型(C)を追加
start_children([{M, F, A, C} | ChildSpecList]) ->
  % apply は、動的な関数呼び出し
	% catch は、
  case (catch apply(M, F, A)) of
	  {ok, Pid} ->
		  [{Pid, {M, F, A, C}} | start_children(ChildSpecList)];
		_ ->
		  start_children(ChildSpecList)
	end.

restart_child(Pid, ChildList) ->
  {value, {Pid, {M, F, A, C }}} = lists:keysearch(Pid, 1, ChildList),
	{ok, NewPid} = apply(M, F, A),
	[{NewPid, {M, F, A, C}}|lists:keydelete(Pid, 1, ChildList)].

loop(ChildList) ->
  receive
	  % 正常終了
	  {'EXIT', Pid, normal} ->
		  io:format("EXIT normal.~n", []),
		  {value, {Pid, {_, _, _, C }}} = lists:keysearch(Pid, 1, ChildList),
		  io:format("EXIT Process Class:~p~n", [C]),
			case C of
			  % permanentの場合は再起動
			  permanent ->
          NewChildList = restart_child(Pid, ChildList),
					loop(NewChildList);
				% transientの場合はそのまま終了させる
				transient ->
					loop(ChildList)
			end;
	  % 異常終了
    {'EXIT', Pid, _Reason} ->
		  io:format("EXIT other.~n", []),
		  % 異常終了は再起動
		  NewChildList = restart_child(Pid, ChildList),
			loop(NewChildList);
		{stop, From} ->
		  From ! {reply, terminate(ChildList)}
	end.

stop(Name) ->
  Name ! {stop, self()},
	receive {reply, Reply} -> Reply end.

terminate([{Pid, _} | ChildList]) ->
  exit(Pid, kill),
	terminate(ChildList);
terminate(_ChildList) -> ok.
