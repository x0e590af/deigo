%%%-------------------------------------------------------------------
%% @doc deigo top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(deigo_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).
-export([mnesis_create_schema/0, mnesis_create_table/0]).

-define(SERVER, ?MODULE).


%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    %% {ok, { {one_for_all, 0, 1}, []} }.
    %% 获取端口配置参数，找不到时返回默认端口 ?DEF_PORT

    {ok, ListenPort} = application:get_env(deigo,listen_port),

    lager:info("listen_port : ~p", [list_to_integer(ListenPort)]),

  mnesis_create_schema(),
  mnesia:start(),
    mnesis_create_table(),


    ranch:start_listener(deigo,
        ranch_tcp, [{port, list_to_integer(ListenPort)}, {max_connections, 10000}], dora_protocol, []),





    {ok, {{one_for_one, 10, 10}, []}}.

%%====================================================================
%% Internal functions
%%====================================================================


mnesis_create_schema() ->



  Nodes = [node()|nodes()],
  lager:info("server:~p", [Nodes] ),


  rpc:multicall(Nodes, mnesia, stop, []),
  mnesia:delete_schema(Nodes),
  mnesia:create_schema(Nodes),
  rpc:multicall(Nodes, mnesia, start, []).



mnesis_create_table() ->


  Tables = [
    deigo_mnesia_table
  ],

  lists:foreach(fun(T)->

    lager:info("create table :~p", [T] ),
    %% 创建表
    case  lists:member(T,  mnesia:system_info(tables)) of
      true ->
        already_exists;
      _ ->
        mnesia:create_table(T,[{disc_copies,[node()|nodes()]}])

    end

   end,Tables).