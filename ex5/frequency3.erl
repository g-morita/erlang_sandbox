-module(frequency3).
-export([start/0, stop/0, allocate/0, deallocate/1]).
-export([init/0, get_frequencies/0, loop/1, call/1, reply/2, allocate/2, deallocate/3, count/2, count/3]).

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
  [10, 11, 12, 13, 14, 15].
 
% ループデータ
loop(Frequencies) ->
  receive
    {request, Pid, allocate} ->
      {NewFrequencies, Reply} = allocate(Frequencies, Pid),
      reply(Pid, Reply),
      loop(NewFrequencies);
    {request, Pid, {deallocate, Freq}} ->
      {NewFrequencies, Reply} = deallocate(Frequencies, Freq, Pid),
      reply(Pid, Reply),
      loop(NewFrequencies);
    {request, Pid, stop} ->
      case Frequencies of
        {[], _} ->
          reply(Pid, ok);
        _ -> 
          reply(Pid, error),
          loop(Frequencies)
    end
  end.

allocate({[], Allocated}, _Pid) ->
  {{[], Allocated}, {error, no_frequency}};
allocate({[Freq|Free], Allocated}, Pid) ->
  io:format("count:~p~n", [count(Allocated, Pid)]),
  case count(Allocated, Pid) < 3 of
    true ->
      { {Free, [{Freq,Pid}|Allocated] }, {ok, Freq}};
    _ ->
      {{Free, Allocated}, allocate_over_error}
  end.

deallocate({Free, Allocated}, Freq, Pid) ->
  % list:member関数を利用する. lists:memberはガードに使えない!?
  case lists:member({Freq,Pid}, Allocated) of
    true -> 
      NewAllocated = lists:keydelete(Freq, 1, Allocated),
      {{[Freq|Free], NewAllocated}, ok};
    _ ->
      {{Free, Allocated}, deallocate_error}
  end.

call(Msg) ->
  ?MODULE ! {request, self(), Msg},
  receive
    {reply, Reply} -> Reply
  end.

% 応答する
reply(Pid, Reply) ->
  Pid ! {reply, Reply}.


count(Allocated, Pid) ->
  count(Allocated, Pid, 0).
	
count([], _Pid, Count) ->
  Count;
count([Head|Tail], Pid, Count) ->
  case Head of
    {_, Pid} ->
      count(Tail, Pid, Count + 1);
    _ ->
      count(Tail, Pid, Count)
  end.
