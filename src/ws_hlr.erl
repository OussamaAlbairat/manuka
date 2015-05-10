-module(ws_hlr).

-export([init/2]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([terminate/3]).

-record(state, {timer_ref}).

%%%%%%%%%%%%%%%%%%%%%%%%%
%%  PRIVATE
%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%

init(Req, Opts) ->
        self() ! post_init,
        {cowboy_websocket, Req, Opts}.

%%%%%%%%%%%%%%%%%%%%%%%%%%

websocket_handle({text, Msg}, Req, State) ->
        io:format("msg in : ~p~n", [Msg]),
        io:format("~p~n", [manuka_lib:handle_message(Msg)]),
        {ok, Req, State};

websocket_handle(_Data, Req, State) ->
        {ok, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%

websocket_info(post_init, Req, _S) ->
        io:format("post_init : all is good."),
        {ok, TRef} = timer:send_interval(timer:seconds(60), do_ping),
        {ok, Req, #state{timer_ref=TRef}};

websocket_info({out, Msg}, Req, State) ->
        io:format("msg out : ~p~n", [Msg]),
	{reply,
             {text, <<Msg/binary>>},
             Req, State};

websocket_info(pre_stop, Req, State) ->
        self() ! do_stop,
	{reply,
             {text, <<"Bye : your manuka connection is down!">>},
             Req, State};

websocket_info(do_stop, Req, State) ->
	{stop, Req, State};

websocket_info(do_ping, Req, State) ->
	{reply, {ping, <<"1">>}, Req, State};

websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

terminate(_Reason, _Req, _State=#state{timer_ref=TRef})->
       timer:cancel(TRef),
       ok.
