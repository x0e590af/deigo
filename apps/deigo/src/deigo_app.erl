%%%-------------------------------------------------------------------
%% @doc deigo public API
%% @end
%%%-------------------------------------------------------------------

-module(deigo_app).

-behaviour(application).



-define(APPLICATION, deigo).
-define(HOSTS, hosts).


%% Application callbacks
-export([start/2, stop/0, leave/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->

    ensure_dir(),

    Nodes = config_nodes(),
    lager:info("Nodes : ~p", [Nodes]),

    ensure_ok(init_schema(Nodes)),

    deigo_sup:start_link().

%%--------------------------------------------------------------------


stop() ->

  Nodes = [node() | nodes()],

  rpc:multicall(Nodes, mnesia, stop, []),

  ok.

%%====================================================================
%% Internal functions
%%====================================================================



config_nodes() ->

    case application:get_env(?APPLICATION, ?HOSTS) of
        {ok, Nodes} when is_list(Nodes) ->
            [N || N <- Nodes, N =/= node()];
        _ ->
            []
    end.


ensure_dir() ->

    Dir = mnesia:system_info(directory) ++ "/",

    case filelib:ensure_dir(Dir) of
        ok ->
            ok;
        {error, Reason} ->
            throw({error, {cannot_create_mnesia_dir, Dir, Reason}})
    end.



running_nodes() ->
    mnesia:system_info(running_db_nodes).

init_schema(Nodes) ->

    mnesia:start(),
    case mnesia:change_config(extra_db_nodes, Nodes -- [node()]) of
        {ok, []} ->
            case running_nodes() -- [node()] of
                [] ->
                    mnesia:stop(),
                    mnesia:create_schema([node()]),
                    mnesia:start();
                _ ->
                    ok
            end;
        {ok, _} ->
            copy_schema(node());
        Error ->
            Error
    end.

copy_schema(Node) ->
    case mnesia:change_table_copy_type(schema, Node, disc_copies) of
        {atomic, ok} ->
            ok;
        {aborted, {already_exists, schema, Node, disc_copies}} ->
            ok;
        {aborted, Error} ->
            {error, Error}
    end.

leave() ->
  leave(node()).

leave(Node) ->

  Nodes = mnesia:system_info(db_nodes),
  Ret =
    case [N || N <- Nodes, N =:= Node] of
      [] ->
        node_not_in_cluster;
      _ ->
        %% try to stop mneisa on that node
        rpc:call(Node, mnesia, stop, []),
        RunningNodes = [N1 || N1 <- mnesia:system_info(running_db_nodes), N1 =/= Node],
        lists:any(fun(Other) ->
          case rpc:call(Other, mnesia, del_table_copy, [schema, Node]) of
            {atomic, ok} -> true;
            _ -> false
          end
                  end, RunningNodes)
    end,
  case Ret of
    true ->
      rpc:call(Node, mnesia, delete_schema, [[Node]]),
      ok;
    E -> {error, E}
  end.



%% ensure ok
ensure_ok(ok) ->
    ok;
ensure_ok({error, {_Node, {already_exists, _Node}}}) ->
    ok;
ensure_ok({badrpc, Reason}) ->
    throw({error, {badrpc, Reason}});
ensure_ok({error, Reason}) ->
    throw({error, Reason});
ensure_ok(Error) ->
    throw(Error).
