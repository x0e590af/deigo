%%%-------------------------------------------------------------------
%%% @author x0e590af
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 三月 2018 下午9:40
%%%-------------------------------------------------------------------
-module(deigo_opt).
-author("x0e590af").

-export([
  keys/2,
  write/1,
  read/2,
  delete/2,
  delete_object/1,
  clear_table/1,
  select/2
]).


keys(Tab,<<"*">>) ->
  mnesia:dirty_all_keys(Tab);

keys(Tab,Key) ->
  mnesia:dirty_read(Tab, Key).



select(Tab,MatchSpec) ->
  Sel = fun(Tab1,MatchSpec1) -> mnesia:select(Tab1,MatchSpec1) end,
  mnesia:activity(sync_dirty,Sel,[Tab,MatchSpec],mnesia_frag).

write(Rec)->
  Write = fun(Rec1) ->
    case mnesia:write(Rec1) of
      ok ->
        ok;
      Res ->
        Res
    end
   end,
  mnesia:activity(sync_dirty, Write,[Rec],mnesia_frag).

read(Tab,Key) ->
  Read = fun(Tab1,Key1) ->
    case mnesia:read({Tab1,Key1}) of
      [ValList] ->
        ValList;
      Res ->
        Res
    end
         end,
  ValList = mnesia:activity(sync_dirty, Read, [Tab,Key], mnesia_frag),
  ValList.

clear_table(Tab) ->
  Del = fun(Tab1) -> mnesia:clear_table(Tab1) end,
  mnesia:activity(sync_dirty, Del, [Tab], mnesia_frag).

delete_object(Rec) ->
  Del = fun(Rec1) -> mnesia:delete_object(Rec1) end,
  mnesia:activity(sync_dirty, Del, [Rec], mnesia_frag).

delete(Tab,Key)->
  Del = fun(Tab1,Key1) -> mnesia:delete({Tab1,Key1}) end,
  mnesia:activity(sync_dirty, Del, [Tab,Key], mnesia_frag).