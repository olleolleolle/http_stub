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

```http_stub``` is similar in motivation to the ```fakeweb``` gem, although ```http_stub``` provides a separately running HTTP process whose responses can be faked / stubbed.

```http_stub``` appears to be very similar in purpose to the ```HTTParrot``` and ```rack-stubs``` gems, although these appear to be inactive.

Installation
------------

In your Gemfile include:

```ruby
    gem 'http_stub'
```

Usage
-----

### Starting Server ###

Start a ```http_stub``` server via a rake task, generated via ```http_stub```:

```ruby
    require 'http_stub/rake/task_generators'

    HttpStub::Rake::DaemonTasks.new(name: :some_server, port: 8001) # Generates 'some_server:start', 'some_server:stop', 'some_server:restart', 'some_server:status' tasks

    HttpStub::Rake::ServerTasks.new(name: :some_server, port: 8001) # Generates 'some_server:start:foreground' task
```

### Stubbing Server Responses ###

### What is a stub? ###

A unit of configuration that matches an incoming server request to a response.

### What is a stub activator? ###

A unit of configuration that activates, or enables, a stub when a url is hit on the server.

#### Stub via API ####

```HttpStub::Configurer``` offers an API to configure a stub server via the class and instance methods ```stub_activator```, ```stub!``` and ```activate!```.
These methods issue HTTP requests to the server, configuring it's responses.  An example follows:

```ruby
    class AuthenticationService
        include HttpStub::Configurer

        server "localhost" # Often localhost for automated test purposes
        port 8001 # The server port number

        # Register stub for POST "/"
        stub! "/", method: :post, response: { status: 201 }
        # Register stub for POST "/" when GET "/unavailable" request is made
        stub_activator "/unavailable", "/", method: :post, response: { status: 404 }

        def unavailable!
            activate!("/unavailable") # Activates the "/unavailable" stub
        end

        def deny_access_for!(username)
            # Registers another stub for POST "/" matching on headers and parameters
            stub!("/", method:     :get,
                       headers:    { api_key: "some_fixed_key" },
                       parameters: { username: username },
                       response:   { status: 403 })
        end

    end
```

The ```stub!``` and ```stub_activator``` methods share the same signatures, except a ```stub_activator``` accepts an
activation url as the first argument.

A stubs uri, parameter and header values accepted in the ```stub!``` and ```stub_activator``` methods can be
regular expressions:

```ruby
    stub! /prefix\/[^\/]*\/postfix/, method: :post, response: { status: 200 }

    stub_activator "/activate_this", /prefix\/[^\/]+\/postfix/,
                   method:     :post,
                   headers:    { api_key: /^some_.+_key$/ },
                   parameters: { username: /^user_.+/ },
                   response:   { status: 201 }
```

Parameter and header values can also be mandatory omissions, for example:

```ruby
    stub! "/some/path",
          method:     :post,
          headers:    { header_name: :omitted },
          parameters: { parameter_name: :omitted },
          response:   { status: 201 }
```

Responses may contain headers, for example:

```ruby
    stub! /prefix\/[^\/]*\/postfix/,
          method: :post,
          response: { status:  201,
                      headers: { "content-type" => "application/xhtml+xml",
                                 "location" => "http://some/resource/path" } }
```

Responses may contain files, for example:

```ruby
    stub! "/some/resource/path",
          headers: { "Accept": "application/pdf" },
          method: :get,
          response: { status:  200,
                      headers: { "content-type" => "application/pdf" },
                      body: { file: { path: "/some/path/on/disk.pdf", name: "resource.pdf" } } }
```

Responses may also impose delays, for example:

```ruby
    stub! /prefix\/[^\/]*\/postfix/, method: :post, response: { status: 200, delay_in_seconds: 8 }
```

The stubs known by the server can also be cleared via class methods ```clear_activators!``` and ```clear_stubs!```.

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

    HttpStub::Rake::DaemonTasks.new(name: :some_server, port: 8001, configurer: MyConfigurer) # Generates 'some_server:start' task which also initializes the configurer

    HttpStub::Rake::ServerTasks.new(name: :some_server, port: 8001, configurer: MyConfigurer) # Generates 'some_server:configure' task
```

An initialization callback is available, useful should you wish to control stub data via Configurer state:

```ruby
    class FooService
        include HttpStub::Configurer

        cattr_accessor :some_state

        def self.on_initialize
          stub! "/registered_on_initialize", method: :get, response: { body: some_state }
        end
    end
```

```ruby
    FooService.some_state = "bar" # Establishes the response body of the on_initialize stub
    FooService.initialize!
```

```remember_stubs``` remembers the stubs so that the state can be recalled in future.

```recall_stubs!``` recalls the remembered stubs and is often used on completion of tests to return the server to a known state:

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
A GET request to /stubs/activators returns HTML listing all activators with links for each one - very useful for
changing the behavior of the server on-the-fly.

To diagnose the state of the server, a GET request to /stubs returns HTML listing all stubs, in top-down priority order.

### Request configuration rules ###

#### uri and method (mandatory) ####

Only subsequent requests matching these criteria will respond with the configured response.
Stubs for GET, POST, PUT, DELETE, PATCH and OPTIONS methods are supported.

#### headers (optional) ####

When included, requests containing headers matching these names and values will return the stub response.
Due to header name rewriting performed by Rack, header name matches are case-insensitive and consider underscores and hyphens to be synonymous.
The 'HTTP_' prefix added to the header names by Rack is removed prior to any comparison.
Requests containing additional headers will also match.

#### parameters (optional) ####

When included, requests containing parameters matching these names and values will return the stub response.
The name match is case sensitive.
Requests containing additional parameters will also match.

#### Match Order ####

The most-recent matching configured stub request wins.

Languages other than Ruby
-------------------------

```http_stub``` support other languages via it's REST API.

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
        "uri":        "some-unique-value",
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
        "headers": {
            "a_header": "control:omitted",
        },
        "parameters": {
            "a_param": "control:omitted",
        }
    }
```

DELETE to /stubs in order to clear configured stubs.

#### /stubs/memory ####

POST to /stubs/memory to remember the current stubs for future use.
GET /stub/memory to recall the the remembered stubs.

### /stubs/activators ###

To configure a stub activator, POST to /stubs/activators with the following JSON payload:

```javascript
    {
        "activation_uri": "/some/activation/path",
        // remainder same as stub request...
    }
```

To activate a stub activator, GET the activation_uri.

DELETE to /stubs/activators in order to clear configured stub activators.

Requirements
------------

* Ruby >= 1.9.3
* Rack server
