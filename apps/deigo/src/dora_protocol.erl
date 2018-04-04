%%%-------------------------------------------------------------------
%%% @author x0e590af
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 一月 2018 下午6:16
%%%-------------------------------------------------------------------
-module(dora_protocol).
-author("x0e590af").

-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).



-record(state, {socket, transport}).

%% API.

start_link(Ref, Socket, Transport, Opts) ->
  {ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
%init([]) -> {ok, undefined}.

init({Ref, Socket, Transport, _Opts = []}) ->

  ok = ranch:accept_ack(Ref),
  ok = Transport:setopts(Socket, [{active, once}]),
  gen_server:enter_loop(?MODULE, [], #state{socket=Socket, transport=Transport}).

handle_info({tcp, Socket, Data}, State=#state{socket=Socket, transport=Transport}) when byte_size(Data) > 1 ->


  Result = deigo_parse:parse(Data),

  try
    Response = execute(Result),
    Transport:setopts(Socket, [{active, once}]),
    Transport:send(Socket, Response)
  catch
    _:_ ->
    Error = deigo_parse:reply_error(<<"Error Command">>),
    Transport:setopts(Socket, [{active, once}]),
    Transport:send(Socket,Error )

  end,


  {noreply, State};


handle_info({tcp_closed, _Socket}, State) ->
  {stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
  {stop, Reason, State};
handle_info(timeout, State) ->
  {stop, normal, State};
handle_info(_Info, State) ->
  {stop, normal, State}.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

execute({array, [{bulk, <<"COMMAND">>}]}) ->

  deigo_server:command(<<>>);




execute({array, [{bulk, <<"INITDB">>}]}) ->

  deigo_server:initdb();

execute({array, [{bulk, <<"INITTB">>}]}) ->

  deigo_server:inittb();

execute({array, [{bulk, <<"FLUSHDB">>}]}) ->

  deigo_server:flushdb({deigo_mnesia_table});




execute({array, [{bulk, <<"BACKUP">>}, {bulk, Path}]}) ->

  deigo_server:backup({deigo_mnesia_table, Path});

execute({array, [{bulk, <<"RESTORE">>}, {bulk, Path}]}) ->

  deigo_server:restore({restore, Path});




execute({array, [{bulk, <<"KEYS">>} | Params]}) ->
  [{bulk,Key}] = Params,
  deigo_server:keys({deigo_mnesia_table, Key});

execute({array, [{bulk, <<"GET">>}, {bulk, Key}]}) ->
  deigo_server:get({deigo_mnesia_table, Key});

execute({array, [{bulk, <<"SET">>} | Params]}) ->
  [{bulk,Key},{bulk,Value}] = Params,
  deigo_server:set({deigo_mnesia_table,Key, Value});





execute({array, [{bulk, <<"HSET">>} | Params]}) ->
  [{bulk,Key}, {bulk,Field},{bulk,Value}] = Params,
  deigo_server:hset({deigo_mnesia_table,Key, Field, Value});

execute({array, [{bulk, <<"HGET">>} | Params]}) ->
  [{bulk,Key}, {bulk,Field}] = Params,
  deigo_server:hget({deigo_mnesia_table,Key, Field});

execute({array, [{bulk, <<"HDEL">>} | Params]}) ->
  [{bulk,Key},{bulk,Field}] = Params,
  deigo_server:hdel({deigo_mnesia_table,[Key,Field]});

execute({array, [{bulk, <<"HMGET">>}, {bulk, Key}]}) ->
  deigo_server:hgetall({deigo_mnesia_table, Key}).





