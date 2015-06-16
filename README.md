http_stub
=========

```fakeweb``` for a HTTP server, informing it to 'fake', or, in the test double vernacular - 'stub' - responses.

Status
------------

[![Build Status](https://travis-ci.org/MYOB-Technology/http_stub.png)](https://travis-ci.org/MYOB-Technology/http_stub)
[![Gem Version](https://badge.fury.io/rb/http_stub.png)](http://badge.fury.io/rb/http_stub)
[![Dependency Status](https://gemnasium.com/MYOB-Technology/http_stub.png)](https://gemnasium.com/MYOB-Technology/http_stub)

Motivation
----------

Need to simulate a HTTP service with which your application integrates?  Enter ```http_stub```.

```http_stub``` is similar in motivation to the ```fakeweb``` gem, although ```http_stub``` provides a separately 
running HTTP process whose responses can be faked / stubbed.

```http_stub``` appears to be very similar in purpose to the ```HTTParrot``` and ```rack-stubs``` gems, although these
 appear to be inactive.

Design
------

```http_stub``` is composed of two parts:
* A HTTP server (Sinatra) that replays known responses when an incoming request matches defined criteria.  The server 
  is run in a dedicated - external - process to the system under test to better simulate the real architecture. 
* A Ruby DSL used to configure the server known as a ```Configurer```

Usage
-----

### Starting a Server ###

Start a ```http_stub``` server via a rake task, generated via ```http_stub```:

```ruby
  require 'http_stub/rake/task_generators'

  HttpStub::Rake::ServerDaemonTasks.new(name: :some_server, configurer: MyConfigurer) # Generates 'some_server:start', 'some_server:stop', 'some_server:restart', 'some_server:status' tasks
                                                                                      # Uses a server host and port defined in the Configurer

  HttpStub::Rake::ServerDaemonTasks.new(name: :some_server, port: 8001)               # When the Configurer DSL is not used, this generates tasks for a server running on localhost with the provided port
```

### Configuring the Server ###

### What is a stub? ###

A unit of configuration that matches an incoming server request to a response.

### What is a scenario? ###

A unit of configuration that activates a set of stubs when a url is hit on the server.

#### Configuration via the Configurer DSL ####

```HttpStub::Configurer``` offers a DSL to configure a ```stub_server```, which is accessible within both class and
instance objects of a ```Configurer```.  The ```stub_server``` is primarily configured via the methods ```add_stub!```,
```add_scenario!``` and ```activate!```.  These methods issue HTTP requests to the server, configuring its responses.
Examples follow:

```ruby
  class SomeRestService
    include HttpStub::Configurer

    stub_server.host = "localhost" # Often localhost for automated test purposes
    stub_server.port = 8001        # The server port number

    # Register stub for GET "/resource"
    stub_server.add_stub! do
      match_requests("/resource", method: :get).with_response(status: 200, body: "resource body")
    end

    # Register stub that triggers other stubs to be registered when a matching request is received
    stub_server.add_stub! do |stub|
      stub.match_requests("/resource", method: :post)
      stub.with_response(status: 201)
      stub.trigger(
        stub_server.build_stub do |triggered_stub|
          triggered_stub.match_requests("/resource", method: :get)
          triggered_stub.with_response(status: 200, body: "created resource")
        end
      )
      end
    end 

    # Register a scenario that is activated when a GET "/unavailable" request is made
    stub_server.add_scenario!("unavailable") do |scenario|
      scenario.add_stub! { match_requests("/resource").with_response(status: 404) }
    end

    def unavailable!
      stub_server.activate!("unavailable") # Activates the "/unavailable" scenario
    end

    # Registers stubs for "/resource" matching on parameters
    def deny_access_to!(username)
      stub_server.add_stub! do
        match_requests("/resource", parameters: { username: username }).with_response(status: 403)
      end
    end

  end
```

When matching a request, a stubs uri, parameter or header values can be regular expressions:

```ruby
  stub_server.add_stub! { match_requests(/prefix\/[^\/]*\/postfix/, method: :post).with_response(status: 200) }

  stub_server.add_stub! do
    match_requests(/prefix\/[^\/]+\/postfix/, method:     :post,
                                              headers:    { api_key: /^some_.+_key$/ },
                                              parameters: { username: /^user_.+/ })
    with_response(status: 201)
  end
```

Parameter and header values can also be mandatory omissions, for example:

```ruby
  stub_server.add_stub! do
    match_requests("/some/path", method:     :post,
                                 headers:    { header_name: :omitted },
                                 parameters: { parameter_name: :omitted })
    with_response(status: 201)
  end
```

Responses may contain headers, for example:

```ruby
  stub_server.add_stub! do
    match_requests(/prefix\/[^\/]*\/postfix/, method: :post)
    with_response(status:  201, headers: { "content-type" => "application/xhtml+xml",
                                           "location" => "http://some/resource/path" })
  end
```

Responses may contain files, for example:

```ruby
  stub_server.add_stub! do
    match_requests("/some/resource/path", headers: { "Accept": "application/pdf" }, method: :get)
    with_response(status:  200, headers: { "content-type" => "application/pdf" },
                                body: { file: { path: "/some/path/on/disk.pdf", name: "resource.pdf" } })
  end
```

Responses may also impose delays, for example:

```ruby
  stub_server.add_stub! do
    match_requests(/prefix\/[^\/]*\/postfix/, method: :post).with_response(status: 200, delay_in_seconds: 8)
  end
```

Scenario's provide a means to conveniently place the server in a known state.  Take these examples:

```ruby
  stub_server.add_scenario!("3_pages_of_resources") do |scenario|
    scenario.add_stub! do
      match_requests("/resource", method: :get)
      with_response(status: 200, body: (1..60).map { |i| "resource_#{i}" }.to_json)
    end
  end

  stub_server.add_scenario!("no_resources") do |scenario|
    scenario.add_stub! { match_requests("/resource", method: :get).with_response(status: 200, body: [].to_json) }
  end
  
  stub_server.add_scenario!("grant_access") do |scenario|
    scenario.add_stub! { match_requests("/login", method: :post).with_response(status: 204) }
  end

  # Scenarios can refer to other scenarios
  stub_server.add_scenario!("happy_flow") do |scenario|
    scenario.activate!("grant_access", "3_pages_of_resources")
  end
```

To activate scenario's:

```ruby
  stub_server.activate!("happy_flow")                   # Activates a scenario
  stub_server.activate!("grant_access", "no_resources") # Activates many scenario's, array is also supported

```

The stubs and scenarios known by the server can be cleared via ```clear_stubs!``` and ```clear_scenarios!```.

##### Configurer Initialization ######

You must tell a Configurer when a server is running, otherwise operations will buffer and never be issued to the
server.

This can be done in one of two ways, via the ```initialize!``` or ```server_has_started!``` class methods.

These methods are similar in purpose although ```initialize!``` also:
* Flushes all buffered requests
* Remembers the buffered stubs allowing the state to be recalled via ```recall_stubs!```

It is recommended that ```initialize!``` is called only once, post server start-up.

Tasks generated by ```http_stub``` will initialize a configurer when provided:

```ruby
  require 'http_stub/rake/task_generators'

  HttpStub::Rake::ServerDaemonTasks.new(name: :some_server, configurer: MyConfigurer) # Generates 'some_server:start' task which also initializes the configurer

  HttpStub::Rake::ServerTasks.new(name: :some_server, configurer: MyConfigurer) # Generates 'some_server:configure' task
```

An initialization callback is available, useful should you wish to control stub data via Configurer state:

```ruby
  class FooService
    include HttpStub::Configurer

    cattr_accessor :some_state

    def self.on_initialize
      stub_server.add_stub! do
        match_requests("/registered_on_initialize", method: :get).with_response(body: some_state)
      end
    end
  end
```

```ruby
  FooService.some_state = "bar" # Establishes the response body of the on_initialize stub
  FooService.initialize!
```

```remember_stubs``` remembers the stubs so that the state can be recalled in future.

```recall_stubs!``` recalls the remembered stubs and is often used on completion of tests to return the server to a
known state:

```ruby
  let(:authentication_service) { AuthenticationService.new }

  # Returns server to post-initialize state
  after(:example) { authentication_service.recall_stubs! }

  describe "when the service is unavailable" do

    before(:example) { authentication_service.unavailable! }

    #...
```

A common use case is to ```recall_stubs!``` before each test is run:

```ruby
  Before do                              # Before each acceptance test scenario
    SomeConfigurer.server_has_started! # Ensure operations are not buffered
    SomeConfigurer.recall_stubs!       # Return to post-initialization state
  end
```

##### Default Response Data #####

Often some aspects of response data is identical, such as content-type headers.
```http_stub``` provides a mechanism for declaring default attributes of a response that will take effect for all
stubbed responses:

```ruby
  class FooService
    include HttpStub::Configurer

    stub_server.response_defaults = { headers: "content-type" => "application/json; charset=utf-8" }

    ...
```

### Informational HTML pages ###

```http_stub``` has been designed to aid exploratory testing and application demonstrations.
A GET request to /stubs/scenarios returns HTML listing all scenarios with activation links for each - very useful for
changing the behavior of the stub server on-the-fly.

To diagnose the state of the server, a GET request to /stubs returns HTML listing all stubs, in top-down priority order.

### Request configuration rules ###

#### uri (mandatory) ####

Only subsequent requests with matching the uri will respond with the configured response.
Regular expressions are permitted.

#### method (optional) ####

Only subsequent requests matching the method will respond with the configured response.
GET, POST, PUT, DELETE, PATCH and OPTIONS is supported.

#### headers (optional) ####

When included, requests containing headers matching these names and values will return the stub response.
Due to header name rewriting performed by Rack, header name matches are case-insensitive and consider underscores and
hyphens to be synonymous.
The 'HTTP_' prefix added to the header names by Rack is removed prior to any comparison.
Requests containing any additional headers will match.
Regular expression values are permitted.
Headers may be mandatory omissions.

#### parameters (optional) ####

When included, requests containing parameters matching these names and values will return the stub response.
The name match is case sensitive.
Requests containing any additional parameters will match.
Regular expression values are permitted.
Parameters may be mandatory omissions.

#### Match Order ####

The most-recently configured matching stub request wins.

Languages other than Ruby
-------------------------

```http_stub``` supports other languages via its REST API.

### /stubs ###

To configure a stub response, POST to /stubs with the following JSON payload:

```javascript
  {
    "id":         "some-unique-value",
    "uri":        "/some/path",
    "method":     "some method",
    "headers":    {
      "a_header":       "a_value",
      "another_header": "another_value"
      ...
    },
    "parameters": {
      "a_param":       "a_value",
      "another_param": "another_value"
      ...
    },
    "response":   {
      "status":           200,
      "body":             "Some body",
      "delay_in_seconds": 8
    },
    "triggers":  [
      {
        "id":        "some-unique-value",
        "uri":        "/some/path",
        "method":     "some method",
        "headers":    {
          "a_header":       "a_value",
          "another_header": "another_value"
          ...
        },
        "parameters": {
          "a_param":       "a_value",
          "another_param": "another_value"
          ...
        },
        "response":   {
          "status":           200,
          "body":             "Some body",
          "delay_in_seconds": 8
        }
        "triggers":   [
          ...
        ]
      },
      ...
    ]
  }
```

Should your response, or trigger responses, contain files, POST to /stubs with a ```multipart/form-data``` content type.
The JSON payload above must be provided in the ```payload``` parameter.
Files are provided in  ```response_file_<id>``` parameters, where ```id``` is the id of the associated stub in the
payload.

The stub uri, header values and parameter values can be regular expressions by prefixing them with ```regexp:```

```javascript
  {
    "uri":        "regexp:/prefix/.+",
    "headers":    {
        "a_header": "regexp:^some.+value$",
    },
    "parameters": {
        "a_param": "regexp:^some.+a_value$",
    }
  }
```

Headers and parameters can also be mandatory omissions by providing the control value: ```control:omitted```:

```javascript
  {
    "uri":        "/some/uri",
    "headers":    {
        "a_header": "control:omitted",
    },
    "parameters": {
        "a_param": "control:omitted",
    }
  }
```

DELETE to /stubs in order to clear all configured stubs.

#### /stubs/memory ####

POST to /stubs/memory to remember the current stubs for future use.
GET /stub/memory to recall the the remembered stubs.

### /stubs/scenarios ###

To configure a scenario, POST to /stubs/scenarios with the following JSON payload:

```javascript
  {
    "name": "some_scenario_name",
    "stubs": [
      {
        // same as stub request...
      },
      {
        // same as stub request...
      },
      ...
    ],
    "triggered_scenario_names": [
      "other_scenario_name",
      "another_scenario_name",
      ...
    ]
  }
```

The number of stubs and other scenarios to activate in a scenario is arbitrary.
To activate a scenario, issue a GET to its name.

DELETE to /stubs/scenarios in order to clear all configured scenarios.

Installation
------------

In your Gemfile include:

```ruby
    gem 'http_stub'
```

Requirements
------------

* Ruby >= 1.9.3
* Rack server
