-module(my_db).
-export([start/0, stop/0, upgrade/1]).
-export([write/2, read/1, delete/1]).
-export([init/0, loop/1]).
-export([code_upgrade/0]).

-vsn(1.0).

start() ->
  register(my_db, spawn(my_db, init, [])).

stop()->
  my_db ! stop.
	
upgrade(Data) ->
  my_db ! {upgrade, Data}.

write(Key, Data) ->
  my_db ! {write, Key, Data}.

read(Key) ->
  my_db ! {read, self(), Key},
  receive Reply -> Reply end.

delete(Key) ->
  my_db ! {delete, Key}.

init() ->
  loop(db:new()).



% アップグレード
code_upgrade() ->
  my_db ! {code_upgrade, self()},
  receive Reply -> Reply end.

loop(Db) ->
  receive
	  % アップグレード
	  {code_upgrade, Pid} ->
       io:format("my_db:code_upgrade_before~n", []),
			 % 古い版の関数を呼び出すと、新しい版のDBが返り、
			 % 且つ、新しい版がロードされる
		   NewDb = db:code_upgrade(Db),
       io:format("my_db:code_upgrade_after~n", []),
			 % デバッグ用に新しい版のDbを返す
       Pid ! NewDb,
       loop(NewDb);
			 
    {write, Key, Data} ->
       loop(db:write(Key, Data, Db));
    {read, Pid, Key} ->
       Pid ! db:read(Key, Db),
       loop(Db);
    {delete, Key} ->
       loop(db:delete(Key, Db));

    stop ->
      db:destroy(Db)
  end. 

