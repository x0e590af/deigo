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
-export([initdb/0,inittb/0, command/1, keys/1, get/1, set/1, flushdb/1]).

%%
%% string
%%



command(Key) ->

  deigo_parse:reply_single(Key).

initdb() ->

  try
    Nodes = [node()|nodes()],
    lager:info("server:~p", [Nodes] ),


    rpc:multicall(Nodes, mnesia, stop, []),
    mnesia:delete_schema(Nodes),
    mnesia:create_schema(Nodes),
    rpc:multicall(Nodes, mnesia, start, []),

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

      lists:foreach(fun(T)->

          case  lists:member(T,  mnesia:system_info(tables)) of
            true ->
              deigo_parse:reply_status(<<"already_exists">>) ;
            _ ->
              mnesia:create_table(T,[{disc_copies,[node()|nodes()]}])

          end

      end,Tables),

      deigo_parse:reply_status(<<"OK">>)

  catch
    _:_ ->
      deigo_parse:reply_error(<<"init error">>)
  end.


flushdb({Database }) ->


    try

        case deigo_opt:clear_table(Database) of

        {atomic,ok} ->
          deigo_parse:reply_status(<<"OK">>);
        _ ->
            deigo_parse:reply_error(<<"ERR Operation against a key holding the wrong kind of value">>)
        end

    catch
        _:_ ->
        deigo_parse:reply_error(<<"ERR wrong number of arguments for 'get' command">>)
    end.



keys({Database,  Key}) ->

  try

      Listkey=  deigo_opt:keys(Database,Key) ,

      case Listkey of
        [_|_]  ->

              deigo_parse:reply_multi([deigo_parse:reply_single(K)|| K <- Listkey]);
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
get({Database,  Key}) ->


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

