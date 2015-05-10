-module(manuka).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    pg2:start(),
    timer:start(),
    manuka_sup:start_link().

stop(_State) ->
    ok.
