%%%-------------------------------------------------------------------
%% @doc rest public API
%% @end
%%%-------------------------------------------------------------------

-module(rest_app).

-behaviour(application).

-define(TAB, hellos_counter).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    init_hellos_counter_tab(?TAB),
    init_cowboy(?TAB),
    rest_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

init_hellos_counter_tab(Tab) ->
    ets:new(Tab, [named_table, public]).

init_cowboy(CountersTab) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            %% For proving hello messages
            {"/hello/:name", rest_hello_handler, #{counters_tab => CountersTab}},
            %% For providing summary of hellos
            {"/hellos/", rest_hello_handler, #{counters_tab => CountersTab}}
        ]}
    ]),
    cowboy:start_clear(rest_hello_listener, [{port, 8080}], 
        #{env => #{dispatch => Dispatch}}).
