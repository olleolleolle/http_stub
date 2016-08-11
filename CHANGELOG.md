** 0.25.1 **

Fix:
* Removed `active_support/json/encoding` dependency as it can inadvertently impact JSON defined in `Configurer`s

** 0.25.0 **

New:
* `GET /http_stub/stubs/matches/last?method=<HTTP method>&uri=<URI part>` retrieves the last match for an endpoint

Misc:
* Administration pages:
  * Matches and misses are listed separately
  * Scenarios are activated in-page
* Refactor:
  * Stubs contain match rules
  * Stub payload is passed through a chain of modifiers

** 0.24.3 **

Fix:
* File responses honour `If-Modified-Since` header

Breaking:
* Response status is no longer configurable when responding with files.  A 200 status is the standard response.
  A 304 status will be returned if an appropriate `if_modified_since` header is issued.

** 0.24.2 **

Fix:
* Honours cross-origin pre-flight requests

** 0.24.1 **

Breaking:
* Dropped Ruby 1.9.3 support (encouraged by `json` gem)

** 0.24.0 **

New:
* Cross-origin resource sharing support via `stub_server.enable :cross_origin_support`

** 0.23.1 **

New:
* `GET /http_stub/stubs/matches` displays the calculated response for stubs whose response has request references

** 0.23.0 **

New:
* Stub response headers and body can contain request header and parameter values
  * e.g. `stub.respond_with { |request| { headers: { location: request.parameter[:redirect_uri] } }`

Misc:
* Introduced [RuboCop](https://github.com/bbatsov/rubocop) source code analysis

** 0.22.4 **

New:
* ```stub_server.external_base_uri``` facilitates links to a stub running in a Docker container
  * Set the external base URI via the environment variable ```STUB_EXTERNAL_BASE_URI```

** 0.22.3 **

Breaking:
* Disabled security measures provided by `Sinatra` and `Rack::Protection` (e.g. `JsonCsrf`, `HttpOrigin`, `RemoteToken`)
  * Stubs can emulate a desired behaviour in stubbed responses

New:
* `stub.respond_with(json: { key: "value" })` supported

Misc:
* Administration page formatting improvements

** 0.22.2 **

Fix:
* Tolerates `rake >= 10.4`

** 0.22.1 **

New:
* `GET /http_stub/stubs/matches` explicitly lists stub matches and misses

** 0.22.0 **

Breaking:
* `POST /http_stub/scenarios/activate` with scenario name parameter activates scenario

New:
* `GET /http_stub/scenarios?name=<scenario name>` retrieves details of scenario with matching name
* Scenario list page contains summary information, with links to activate and view details

Misc:
* Refactor: Scenario names preferred over ID, natural language preferred

** 0.21.0 **

Breaking:
* All administration endpoints are prefixed with 'http_stub', including POSTed configuration

** 0.20.1 **

New:
* Presentation of stubs tweaked in diagnostic pages
* `GET /stubs/matches` includes response data

** 0.20.0 **

New:
* `GET /stubs/matches` lists stub match history
* `DELETE /stubs` also clears matches
* `GET /stubs/:id` displays a stub
* `add_stub!` returns POST /stubs response when configurer has been initialized

Misc:
* Refactor: Introduced `HttpStub::Server::Stub::Match` to encapsulate match logic and rules

** 0.19.2 **

Misc:
* Refactor: Class name mirroring module name preferred over Instance (for aggregates).

** 0.19.1 **

New:
* `add_scenario_with_one_stub!` supports builder as an argument.

** 0.19.0 **

New:
* Server request defaults support.

Breaking:
* ```match_requests` no longer accepts uri as first argument.  It must be provided in the argument hash, e.g. `stub.match_requests(uri: "/some/uri")`
* `add_scenario_with_one_stub!` preferred over `add_one_stub_scenario!`

** 0.18.2 **

New:
* Endpoint templates support building and adding stub to server.

** 0.18.1 **

New:
* Scenarios added via an endpoint template can exclude block

** 0.18.0 **

New:
* `stub_server.endpoint_template` scenario creation support
* `stub_server.add_one_stub_scenario!` simplifies DSL
* `HttpStub::Configurer::Part` aids composing large Configurers

** 0.17.0 **

New:
* request body matching via exact match, regex match and JSON schema validation match.

Breaking:
* `Configurer` host, port and base_uri related methods must now be accessed via the `stub_server`.

** 0.16.0 **

New:
* scenarios

Deprecated:
* stub activators

Breaking:
* Activator paths replaced by activator names.  Calls to `stub_activator` and `activate!` must no longer have '/' prefix.

** 0.12.0 **

Breaking:
* Daemon renamed to ServerDaemon for clarity.
