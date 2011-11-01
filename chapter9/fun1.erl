-module(fun1).
-export([doubleAll/1]).
-export([revAll/1]).
%%-import(lists).

doubleAll([]) ->
    [];
doubleAll([X|Xs]) ->
    [X*2 | doubleAll(Xs)].

revAll([]) ->
    [];
revAll([X|Xs]) ->
    [reverse(X) | revAll(Xs)].

