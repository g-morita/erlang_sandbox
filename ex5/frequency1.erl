-module(frequency1).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/0, get_frequencies/0, loop/1, call/1, reply/2, allocate/2, deallocate/2]).


start() ->
  register(?MODULE, spawn(?MODULE, init, [])).

stop() ->
  call(stop).
  
allocate() ->
  call(allocate).
  
deallocate(Freq) ->
  call({deallocate, Freq}).
	
init() ->
 Frequencies = {get_frequencies(), []},
 loop(Frequencies).

get_frequencies() ->
  [10,11,12].
 
% ループデータ
loop(Frequencies) ->
  receive
	  {request, Pid, allocate} ->
		  {NewFrequencies, Reply} = allocate(Frequencies, Pid),
	    reply(Pid, Reply),
			loop(NewFrequencies);
	  {request, Pid, {deallocate, Freq}} ->
		  NewFrequencies = deallocate(Frequencies, Freq),
	    reply(Pid, ok),
			loop(NewFrequencies);
	  {request, Pid, stop} ->
	    reply(Pid, ok)
  end.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  { {Free, [{Freq, Pid} | Allocated] }, {ok, Freq}}.
deallocate({Free, Allocated}, Freq) ->
  NewAllocated = lists:keydelete(Freq, 1, Allocated),
	{[Freq|Free], NewAllocated}.

call(Msg) ->
  ?MODULE ! {request, self(), Msg},
  receive
    {reply, Reply} -> Reply
  end.

% 応答する
reply(Pid, Reply) ->
  Pid ! {reply, Reply}.
