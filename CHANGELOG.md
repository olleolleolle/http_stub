** 0.12.0 **

Daemon renamed to ServerDaemon for clarity.

** 0.16.0 **

Added scenarios.
Deprecated stub activators.

Breaking changes:
* Activator paths replaced by activator names.  Calls to ```stub_activator`` and ```activate!``` must no longer have '/' prefix.
 
 ** 0.17.0 **
 
Added request body matching via exact match, regex match and JSON schema validation match.

Breaking changes:
* ```Configurer``` host, port and base_uri related methods must now be accessed via the ```stub_server```.

 ** 0.18.0 **
 
Added stub_server.endpoint_template scenario creation support.
Added stub_server.add_one_stub_scenario to simplify DSL.
Added HttpStub::Configurer::Part to aid composing large Configurers.

 ** 0.18.1 **

Scenarios added via an endpoint template can exclude block.

 ** 0.18.2 **
 
Endpoint templates support building and adding stub to server.

 ** 0.19.0 **
 
Server request defaults supported.

Breaking changes:
* ```match_requests``` no longer accepts uri as first argument.  It must be provided in the argument hash, e.g. ```stub.match_requests(uri: "/some/uri")```
* ```add_scenario_with_one_stub!``` preferred over ```add_one_stub_scenario!```
