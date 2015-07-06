** 0.12.0 **

Breaking:
* Daemon renamed to ServerDaemon for clarity.

** 0.16.0 **

New:
* scenarios

Deprecated:
* stub activators

Breaking:
* Activator paths replaced by activator names.  Calls to ```stub_activator`` and ```activate!``` must no longer have '/' prefix.
 
 ** 0.17.0 **

New: 
* request body matching via exact match, regex match and JSON schema validation match.

Breaking:
* ```Configurer``` host, port and base_uri related methods must now be accessed via the ```stub_server```.

 ** 0.18.0 **

New:
* ```stub_server.endpoint_template``` scenario creation support
* ```stub_server.add_one_stub_scenario!``` simplifies DSL
* ```HttpStub::Configurer::Part``` aids composing large Configurers

 ** 0.18.1 **

New:
* Scenarios added via an endpoint template can exclude block

 ** 0.18.2 **

New:
* Endpoint templates support building and adding stub to server.

 ** 0.19.0 **
 
New:
* Server request defaults support.

Breaking:
* ```match_requests``` no longer accepts uri as first argument.  It must be provided in the argument hash, e.g. ```stub.match_requests(uri: "/some/uri")```
* ```add_scenario_with_one_stub!``` preferred over ```add_one_stub_scenario!```

 ** 0.19.1 **

New:
* ```add_scenario_with_one_stub!``` supports builder as an argument.

 ** 0.19.2 **

Misc: 
* Refactor: Class name mirroring module name preferred over Instance (for aggregates).

** 0.20.0 **

New:
* GET /stubs/matches lists stub match history
* DELETE /stubs also clears matches
* GET /stubs/:id displays a stub
* ```add_stub!``` returns POST /stubs response when configurer has been initialized

Misc:
* Refactor: Introduced ```HttpStub::Server::Stub::Match``` to encapsulate match logic and rules

** 0.21.0 **

New:
* Presentation of stubs tweaked in diagnostic pages
* Get /stubs/matches includes response data
