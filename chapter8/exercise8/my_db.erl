-module(my_db).
-export([start/0, stop/0, upgrade/1]).
-export([write/2, read/1, delete/1]).
-export([init/0, loop/1]).
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

loop(Db) ->
  receive
    {write, Key, Data} ->
       loop(db:write(Key, Data, Db));
    {read, Pid, Key} ->
       Pid ! db:read(Key, Db),
       loop(Db);
    {delete, Key} ->
       loop(db:delete(Key, Db));
    {upgrade, Data} ->
      NewDb = db:convert(Data, Db),
      my_db:loop(NewDb);
    stop ->
      db:destroy(Db)
  end. 

