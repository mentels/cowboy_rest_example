-module(rest_hello_handler).

-export([init/2,
        allowed_methods/2,
        content_types_provided/2,
        to_html/2]).

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    ContentTypes = [{{<<"text">>, <<"html">>, '*'}, to_html}],
    {ContentTypes, Req, State}.

to_html(#{path := <<"/hellos">>} = Req, #{counters_tab := Tab} = State) ->
    Hellos = build_hellos_stats(Tab),
    {Hellos, Req, State};
to_html(Req, #{counters_tab := Tab} = State) ->
    Name = cowboy_req:binding(name, Req),
    update_hellos_counter(Name, Tab),
    {<<"Hello ", Name/binary, "!">>, Req, State}.

update_hellos_counter(Name, Tab) ->
    ets:update_counter(Tab, Name, 1, {Name, 0}).

build_hellos_stats(Tab) ->
    << <<Name/binary, ": ", (integer_to_binary(Count))/binary, <<"\n">>/binary >>
        || {Name, Count} <- ets:tab2list(Tab) >>.