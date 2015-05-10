-module(web_svr).
-behaviour(gen_server).

-export([start_link/0]).
-export([stop/0]).
-export([init/1
         , handle_call/3
         , handle_cast/2
         , handle_info/2
         , code_change/3
         , terminate/2]).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link() ->
     gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
     gen_server:call(?MODULE, stop).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%

init([]) ->
     Dispatch = cowboy_router:compile([
		     {'_', [{"/", ws_hlr, []}]}
	        ]),
     {ok, _} = cowboy:start_http(http, 100, [{port, 8082}],
		[{env, [{dispatch, Dispatch}]}]),
     {ok, ?MODULE}.

handle_call(_Event, _From, State) ->
      {noreply, ok, State}.

handle_cast(_Event, State) ->
      {noreply, State}.

handle_info(_Event, State) ->
      {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
      {ok, State}.

terminate(_Reason, _State) ->
      ok.

