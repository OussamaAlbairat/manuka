-module(manuka_sup).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_Args) ->
    { ok,
        {
          { one_for_one, 5, 10},
          [ { web_sup,
              { web_sup, start_link, []},
              permanent, 1000, supervisor, [web_sup]
            }
          ]
        }
    }.


