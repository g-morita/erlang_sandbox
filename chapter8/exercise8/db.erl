-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).
-export([code_upgrade/1]).

% 問題が指定した関数
code_upgrade(Db) ->
  io:format("list_db:code_upgrade~n", []),

  % ここで gb_trees_db がロードされる
  code:load_file(db),
  % gb_trees_db の関数呼び出し
  db:code_upgrade(Db).



new() -> [].

destroy(_) -> ok.

write(Key, Element, Db) ->
  % ログ出力
  io:format("list_db:write~n", []),
  [{Key, Element}| Db].

delete(Key, Db) -> delete_acc(Key, Db, []).
delete_acc(_, [], Acc) -> Acc;
delete_acc(Key, [{Key,_}|T], Acc) -> delete_acc(Key, T, Acc);
delete_acc(Key, [{K,E}|T], Acc) -> delete_acc(Key, T, [{K,E}|Acc]).

read(_, []) -> {error, instance};
read(Key, [{Key,Element}|_]) ->
  % ログ出力
  io:format("list_db:read~n", []),
  {ok, Element};
read(Key, [_|T]) -> read(Key, T).

match(Element, Db) -> match_acc(Element, Db, []).
match_acc(_, [], Acc) -> Acc;
match_acc(Element, [{Key,Element}|T], Acc) ->
  match_acc(Element, T, [Key|Acc]);
match_acc(Element, [_|T], Acc) ->
  match_acc(Element, T, Acc).


