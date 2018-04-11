%%%-------------------------------------------------------------------
%%% @author x0e590af
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 三月 2018 下午9:42
%%%-------------------------------------------------------------------
-module(deigo_server).
-author("x0e590af").



%% API

-export([command/1]).
-export([initdb/0, inittb/0, flushdb/1]).
-export([keys/1, get/1, set/1]).
-export([hset/1, hget/1, hgetall/1, hdel/1]).
-export([backup/1, restore/1]).

%%
%% string
%%


remove_hash([], Map, N) ->
  {N, Map};
remove_hash([H | T], Map, N) ->
  case maps:is_key(H, Map) of
    true ->
      remove_hash(T, maps:remove(H, Map), N + 1);
    _ ->
      remove_hash(T, Map, N)
  end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
command(Key) ->

  deigo_parse:reply_single(Key).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initdb() ->



  try



    Nodes = [node() | nodes()],

    rpc:multicall(Nodes, mnesia, stop, []),
    mnesia:delete_schema(Nodes),
    mnesia:create_schema(Nodes),
    rpc:multicall(Nodes, mnesia, start, []),

    inittb(),

    deigo_parse:reply_status(<<"OK">>)

  catch
    _:_ ->
      deigo_parse:reply_error(<<"init error">>)
  end.




inittb() ->

  try


    Tables = [
      deigo_mnesia_table
    ],

    lists:foreach(fun(T) ->

      case lists:member(T, mnesia:system_info(tables)) of
        true ->
          deigo_parse:reply_status(<<"already_exists">>);
        _ ->
          mnesia:create_table(T, [{disc_copies, [node() | nodes()]}])

      end

                  end, Tables),

    deigo_parse:reply_status(<<"OK">>)

  catch
    _:_ ->
      deigo_parse:reply_error(<<"init error">>)
  end.


flushdb({Database}) ->


  try

    case deigo_opt:clear_table(Database) of

      {atomic, ok} ->
        deigo_parse:reply_status(<<"OK">>);
      _ ->
        deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
    end

  catch
    _:_ ->
      deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
  end.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
restore({restore, Path}) ->


  try

    case deigo_opt:restore(Path) of

      ok ->
        deigo_parse:reply_status(<<"OK">>);
      _ ->
        deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
    end

  catch
    _:_ ->
      deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
  end.


backup({Database, Path}) ->


  try

    case deigo_opt:backup(Database, Path) of

      ok ->
        deigo_parse:reply_status(<<"OK">>);
      _ ->
        deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
    end

  catch
    _:_ ->
      deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
keys({Database, Key}) ->

  try

    Listkey = deigo_opt:keys(Database, Key),

    case Listkey of
      [_ | _] ->

        deigo_parse:reply_multi([deigo_parse:reply_single(K) || K <- Listkey]);
      [] ->
        deigo_parse:reply_single(<<>>);
      _ ->
        deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
    end

  catch
    _:_ ->
      deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
  end.


%% get
get({Database, Key}) ->


  %deigo_opt:read(Database, Key).
  try

    case deigo_opt:read(Database, Key) of
      {Database, Key, Value} ->

        deigo_parse:reply_single(Value);
      [] ->
        deigo_parse:reply_single(<<>>);
      _ ->
        deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
    end
  catch
    _:_ ->
      deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
  end.


%% set
%% todo: expire
set({Database, Key, Value}) ->

  try

    case deigo_opt:write({Database, Key, Value}) of
      ok ->
        deigo_parse:reply_status(<<"OK">>);
      _ ->
        deigo_parse:reply_error(<<"ERR syntax error">>)
    end
  catch
    _:_ ->
      deigo_parse:reply_error(<<"FAULT syntax error">>)
  end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% hset
hset({Database, Key, F, V}) ->
  try
    case deigo_opt:read(Database, Key) of
      {Database, Key, Map} ->
        N = case maps:is_key(F, Map) of
              true ->
                0;
              _ ->
                1
            end,
        deigo_opt:write({Database, Key, maps:put(F, V, Map)}),
        deigo_parse:reply_integer(N);
      [] ->
        deigo_opt:write({Database, Key, maps:put(F, V, maps:new())}),
        deigo_parse:reply_integer(1);
      _ ->
        deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
    end
  catch
    _:_ ->
      deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
  end.

%% hget
hget({Database, Key, K}) ->

  try
    case deigo_opt:read(Database, Key) of

      {Database, Key, Map} ->
        N = case maps:is_key(K, Map) of
              true ->
                maps:get(K, Map);
              _ ->
                <<>>
            end,
        deigo_parse:reply_single(N);
      [] ->
        deigo_parse:reply_single(<<>>);
      _ ->

        deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
    end
  catch
    _:_ ->
      deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
  end.


%% hgetall
hgetall({Database, Key}) ->
  try
    case deigo_opt:read(Database, Key) of
      {Database, Key, Map} ->
        deigo_parse:reply_multi(
          lists:flatten(
            [[deigo_parse:reply_single(K), deigo_parse:reply_single(V)] ||
              {K, V} <- maps:to_list(Map)]));
      [] ->
        deigo_parse:reply_multi([], 0, <<>>);

      _ ->
        deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
    end
  catch
    _:_ ->
      deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
  end.

%% hdel
hdel({Database, [Key | Value]}) ->

  try
    case deigo_opt:read(Database, Key) of

      {Database, Key, Map} ->
        {Number, NewMap} = remove_hash(Value, Map, 0),
        deigo_opt:write({Database, Key, NewMap}),
        deigo_parse:reply_integer(Number);
      [] ->
        deigo_parse:reply_integer(0);
      _ ->
        deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
    end

  catch
    _:_ ->
      deigo_parse:reply_error(<<"WRONGTYPE Operation against a key holding the wrong kind of value">>)
  end.