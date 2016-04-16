%% Experiment with the Cowboy web server.
-module(simple_web_server).

%% Module API.
-export([start/1, stop/0]).

%% Exports required of a dispatcher.
-export([init/2, handle/2, terminate/3]).

start(Port) ->
    %ok = application:start(crypto),    
    ok = application:start(ranch),    
    ok = application:start(cowlib),
    ok = application:start(cowboy),
    
    % Number of parallel processes to accept HTTP connections.
    N_acceptors = 10,

    % Routes are {URIhost, list({URIpath Handler, Opts}}.
    Dispatch = cowboy_router:compile([
        {'_', [{'_', simple_web_server, []}]}]),

    % Start the web server.
    cowboy:start_http(
        simple_web_server, 
        N_acceptors, 
        [{port, Port}], 
        [{env, [{dispatch, Dispatch}]}]).

stop() ->
    application:stop(cowboy),
    application:stop(cowlib),
    application:stop(ranch),
    %application:stop(crypto),
    ok.

%% Dispatcher functions.

init(Req, Opts) ->
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        <<"Hello Erlang!">>,
        Req),
    {ok, Req2, Opts}.

%init({tcp, http}, Req, _Opts) ->
%    {ok, Req, undefined}.

handle(Req, State) ->
    {Path, Req1} = cowboy_req:path(Req),
    Response = read_file(Path),
    {ok, Req2} = cowboy_req:reply(200, [], Response, Req1),
    {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
    ok.

%% Internal functions.
read_file(Path) ->
    File = ["."|binary_to_list(Path)],
    case file:read_file(File) of
        {ok, Bin} -> Bin;
        _ -> ["<pre>cannot read:", File, "</pre>"]
    end.

