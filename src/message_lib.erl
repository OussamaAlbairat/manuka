-module(message_lib).

-export([decode/1,
         encode/3]).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%

decode(Msg) when is_binary(Msg) ->
     io:format("decoding Msg : ~p~n", [Msg]),
     case catch jsx:decode(Msg) of
        Json when is_list(Json) ->
             Type = type_map(proplists:get_value(<<"type">>, Json)),
             io:format("type of Msg : ~p~n", [Type]),
             scan_json(Type, Json);
        _ -> {error, <<"parse error of : ", Msg/binary>>}
     end;

decode(_) ->
     {error, <<"decode : unknown operation">>}.

%%%%%%%%%%%%%%%%%%%%%%%%%%

encode(out, Token, Data)
            when is_binary(Token) andalso is_binary(Data) ->
      jsx:encode([{type, data},
                  {content,
                        [ {token, Token}, {data, Data} ]
                  }
                 ]);

encode(_, _, _) ->
     <<"error">>.

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  PRIVATE
%%%%%%%%%%%%%%%%%%%%%%%%%%

% instead of using list_to_atom
type_map(<<"register">>) ->
     register;

type_map(<<"unregister">>) ->
     unregister;

type_map(<<"subscribe">>) ->
     subscribe;

type_map(<<"unsubscribe">>) ->
     unsubscribe;

type_map(<<"dispatch">>) ->
     dispatch;

type_map(_) ->
     error.

%%%%%%%%%%%%%%%%%%%%%%%%%%
% receives  : {"type":"register", "content":[{"token":"tok1"},{"token":"tok2"}]}
% returns   : {register, [<<"tok1">>, <<"tok2">>]} | {error. <<"reason">>}
scan_json(Type, Json)
          when is_atom(Type) andalso Type =/= error andalso is_list(Json) ->
     get_content({Type, []}, proplists:get_value(<<"content">>, Json));

scan_json(_, _) ->
     {error, <<"parse error of json msg : unknown type.">>}.

%%%%%%%%%%%%%%%%%%%%%%%%%%

get_content({register, _List}, Content) when is_list(Content) ->
     {register, [Token || [{<<"token">>, Token}] <- Content]};

get_content({unregister, _List}, Content) when is_list(Content) ->
     {unregister, [Token || [{<<"token">>, Token}] <- Content]};

get_content({subscribe, _List}, Content) when is_list(Content) ->
     {subscribe, [Token || [{<<"token">>, Token}] <- Content]};

get_content({unsubscribe, _List}, Content) when is_list(Content) ->
     {unsubscribe, [Token || [{<<"token">>, Token}] <- Content]};

get_content({dispatch, _List}, Content) when is_list(Content) ->
     {dispatch, [get_dispatch_msg(Msg) || Msg <- Content]};

get_content(_, _) ->
     {error, <<"parse error of json msg, missing 'content' field.">>}.

%%%%%%%%%%%%%%%%%%%%%%%%%
% receives : [{<<"token">>, <<"t1">>}, {<<"data">>, <<"d1">>}]
% returns  : {<<t1>>, <<"d1">>}
get_dispatch_msg([{<<"token">>, Token}, {<<"data">>, Data}])->
     {Token, Data};

get_dispatch_msg(_) ->
     {error, <<"parse error of json msg : dispatch msg.">>}.

