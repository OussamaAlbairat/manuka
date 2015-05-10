-module(web_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  INTERFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%

init(_Args) ->
    { ok, 
        { 
          { one_for_one, 5, 10},
          [ { web_svr, 
              { web_svr, start_link, []},
              permanent, 1000, worker, [web_svr]  
            }
          ]
        }
    }.
