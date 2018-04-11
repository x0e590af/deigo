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


    ranch:start_listener(dora_protocol,
        ranch_tcp, [{port, list_to_integer(ListenPort)}, {max_connections, 10000}], dora_protocol, []),





    {ok, {{one_for_one, 10, 10}, []}}.

%%====================================================================
%% Internal functions
%%====================================================================

