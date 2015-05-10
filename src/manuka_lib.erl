-module(manuka_lib).

-export([handle_message/1]).

%%%%%%%%%%%%%%%%%%%%%%%%
%   INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%

handle_message(Msg) when is_binary(Msg) ->
      handle_message(message_lib:decode(Msg));

% the service provider creates a group
handle_message({register, Tokens}) when is_list(Tokens) ->
      [pg2:create(Token) || Token <- Tokens];

% the service provider creates a group
handle_message({unregister, Tokens}) when is_list(Tokens)->
      [pg2:delete(Token) || Token <- Tokens];

% the client joins a group
handle_message({subscribe, Tokens}) when is_list(Tokens)->
      [pg2:join(Token, self()) || Token  <- Tokens];

% the client joins a group
handle_message({unsubscribe, Tokens}) when is_list(Tokens) ->
      [pg2:leave(Token, self()) || Token <- Tokens];

% the service provider send data to subscribers
handle_message({dispatch, Msgs}) ->
      [dispatch(Token, Data) || {Token, Data} <- Msgs];

handle_message(_) ->
      [{error, <<"handle_message : unknown operation">>}].

%%%%%%%%%%%%%%%%%%%%%%%%
%   PRIVATE
%%%%%%%%%%%%%%%%%%%%%%%%

dispatch(Token, Data) when is_binary(Token) andalso is_binary(Data) ->
      case pg2:get_members(Token) of
         List when is_list(List) ->
              [Pid ! {out, message_lib:encode(out, Token, Data)} || Pid <- List],
              ok;
         _ -> {error, <<"token not found", Token/binary>>}
      end;

dispatch(_, _) ->
      {error, <<"dispatch : unknown operation">>}.

