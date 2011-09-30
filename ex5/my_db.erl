-module(my_db).
-export([start/0, stop/0, write/2, delete/1, read/1, match/1, init/0, loop/1, call/1, reply/2]).

start() ->
  register(?MODULE, spawn(?MODULE, init, [])).

stop() ->
  call(stop),
  ok.
  
write(Key, Element) ->
  call({write, Key, Element}),
  ok.
  
delete(Key) ->
  call({delete, Key}),
  ok.
  
read(Key) ->
  call({read, Key}),
  ok.
  
match(Element) ->
  match({match, Element}),
  ok.


call(Msg) ->
  ?MODULE ! {request, self(), Msg},
  receive
    {reply, Reply} -> Reply
  end.

init() ->
 loop([]).

% ループデータ Db を利用している
loop(Db) ->
  receive
	  {request, Pid, {read, Key}} ->
		  Key,
		  % 
	    reply(Pid, ok),
			loop(Db);
	  {request, Pid, {write, Key, Element}} ->
  	  Key, Element,
		  % 
	    reply(Pid, ok),
			loop(Db);
	  {request, Pid, {delete, Key}} ->
		  Key,
		  %
	    reply(Pid, ok),
			loop(Db);
	  {request, Pid, {match, Element}} ->
		  Element,
		  %
	    reply(Pid, ok),
			loop(Db);
	  {request, Pid, stop} ->
	    reply(Pid, ok);
  end.


% 応答する
reply(Pid, Reply) ->
  Pid ! {reply, Reply}.
