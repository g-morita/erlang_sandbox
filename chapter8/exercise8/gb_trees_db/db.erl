-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, convert/2]).
-export([code_upgrade/1, insert_table/2]).
-vsn(1.2).

% 問題文に「ESTテーブル」とあったから est モジュールをつかってみたけど、
% どうしても後が続かない。。

%code_upgrade(List) ->
%  io:format("gb_trees_db:code_upgrade~n", []),  
%  T = ets:new(table, [set]),
% insert_table(T, List).

% ETSのテーブルにリスト型DBの要素を登録する。勝手につくった関数。
%insert_table(T, [Element|List]) ->
%  ets:insert(T, Element),
%  insert_table(T, List);
%insert_table(T, []) -> T.

% 問題が指定した関数
% 新しく平衡木のDBをつくり、リスト型DBの要素を登録する
code_upgrade(List) ->
  io:format("gb_trees_db:code_upgrade~n", []),  
  Db = new(),
  insert_table(Db, List).

% 本来は、次回のアップデートに備えたコードが必要なんだろうな。。

% リスト型DBをDBに登録する
insert_table(Db, [{Key, Data}|List]) ->
  NewDb = write(Key, Data, Db),
  insert_table(NewDb, List);
insert_table(Db, []) -> Db.

new() -> gb_trees:empty().

write(Key, Data, Db) ->
  io:format("gb_trees_db:write~n", []),
  gb_trees:insert(Key, Data, Db).

read(Key, Db) ->
  io:format("gb_trees_db:read~n", []),
  case gb_trees:lookup(Key, Db) of
    none         -> {error, instance};
    {value, Data} -> {ok, Data}
  end.

destroy(_Db) -> ok.

delete(Key, Db) -> gb_trees:delete(Key, Db).

convert(dict,Dict) ->
  dict(dict:fetch_keys(Dict), Dict, new());
convert(_, Data) ->
  Data.

dict([Key|Tail], Dict, GbTree) ->
  Data = dict:fetch(Key, Dict),
  NewGbTree  = gb_trees:insert(Key, Data, GbTree),
  dict(Tail, Dict, NewGbTree);
dict([], _, GbTree) -> GbTree.

