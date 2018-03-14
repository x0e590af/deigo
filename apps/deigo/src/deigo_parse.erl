-module(deigo_parse).

-export([
  parse/1,

  reply_error/1,
  reply_integer/1,
  reply_status/1,
  reply_single/1,
  reply_multi/1
]).

parse(<<$+, Rest/binary>>) ->
  case get_line(Rest) of
    {ok, Simple, <<>>} ->
      {simple, Simple};
    {ok, Simple, More} ->
      {simple, Simple, More};
    {incomplete, _Binary} = I ->
      I
  end;
parse(<<$-, Rest/binary>>) ->
  case get_line(Rest) of
    {ok, Error, <<>>} ->
      {error, Error};
    {ok, Error, More} ->
      {error, Error, More};
    {incomplete, _Binary} = I ->
      I
  end;
parse(<<$:, Rest/binary>>) ->
  case get_line(Rest) of
    {ok, Int, <<>>} ->
      {integer, binary_to_integer(Int)};
    {ok, Int, More} ->
      {integer, binary_to_integer(Int), More};
    {incomplete, _Binary} = I ->
      I
  end;
parse(<<$$, Rest/binary>> = Full) ->
  case get_line(Rest) of
    {ok, <<"-1">>, <<>>} ->
      {bulk, null};
    {ok, _Len, <<>>} ->
      {incomplete, Full};
    {ok, _Len, Rest2} ->
      %% TODO use length for checking
      % _Length = binary_to_integer(Len),
      case get_line(Rest2) of
        {ok, Bulk, <<>>} ->
          {bulk, Bulk};
        {ok, Bulk, More} ->
          {bulk, Bulk, More};
        {incomplete, _Binary} ->
          {incomplete, Full}
      end;
    {incomplete, _Binary} = I ->
      I
  end;
parse(<<$*, Rest/binary>>) ->
  case get_line(Rest) of
    {ok, <<"0">>, <<>>} ->
      {array, []};
    {ok, <<"-1">>, <<>>} ->
      {array, null};
    {ok, C, More} ->
      Count = binary_to_integer(C),
      case parse_array(Count, More, []) of
        {array, Values, <<>>} ->
          {array, Values};
        {array, Values, More} ->
          {array, Values, More}
      end
  end.

parse_array(0, Binary, Result) ->
  {array, lists:reverse(Result), Binary};
parse_array(N, Binary, Result) ->
  case parse(Binary) of
    {simple, _Simple} = S ->
      parse_array(N - 1, <<>>, [S | Result]);
    {simple, Simple, More} ->
      parse_array(N - 1, More, [{simple, Simple} | Result]);
    {error, _Error} = E ->
      parse_array(N - 1, <<>>, [E | Result]);
    {error, Error, More} ->
      parse_array(N - 1, More, [{error, Error} | Result]);
    {integer, _Integer} = I ->
      parse_array(N - 1, <<>>, [I | Result]);
    {integer, Integer, More} ->
      parse_array(N - 1, More, [{integer, Integer} | Result]);
    {bulk, _Bulk} = B ->
      parse_array(N - 1, <<>>, [B | Result]);
    {bulk, Bulk, More} ->
      parse_array(N - 1, More, [{bulk, Bulk} | Result]);
    {array, _Array} = A ->
      parse_array(N - 1, <<>>, [A | Result]);
    {array, Array, More} ->
      parse_array(N - 1, More, [{array, Array} | Result])
  end.


%% Get a line or incomplete if there is no \r\n
get_line(Binary) ->
  case re:run(Binary, "\r\n") of
    nomatch ->
      {incomplete, Binary};
    {match, [{Pos, Len}]} ->
      <<Match:Pos/binary, _:Len/binary, Rest/binary>> = Binary,
      {ok, Match, Rest}
  end.

%%=================================================================
%% Reply

reply_status(Status) when is_binary(Status) ->
  <<$+, Status/binary, $\r, $\n>>.
  %<<$+, Status/binary>>.

reply_error(Error) when is_binary(Error) ->
  <<$-, Error/binary, $\r, $\n>>.

reply_integer(Number) when is_integer(Number) ->
  Bin = integer_to_binary(Number),
  <<$:, Bin/binary, $\r, $\n>>.

reply_single(<<>>) ->
  <<"$-1\r\n">>;
reply_single(Data) when is_binary(Data) ->
  Num = integer_to_binary(byte_size(Data)),
  <<$$, Num/binary, $\r, $\n, Data/binary, $\r, $\n>>.

reply_multi(List) ->
  reply_multi(List, 0, <<>>).


%% internal implement

reply_multi([], Number, Result) ->
  Num = integer_to_binary(Number),
  <<
    $*,
    Num/binary,
    $\r, $\n,
    Result/binary
  >>;
reply_multi([H|T], Count, Result) ->
  reply_multi(
    T,
    Count+1,
    <<
      Result/binary,
      H/binary
    >>
  ).