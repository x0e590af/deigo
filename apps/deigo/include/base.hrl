%%%-------------------------------------------------------------------
%%% @author x0e590af
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2018 上午11:29
%%%-------------------------------------------------------------------

-author("x0e590af").


%% record
-record(state,{ref,socket,transport}).
-record(user_info,{pid,socket}).