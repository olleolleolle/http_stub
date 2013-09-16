http_stub
=========

```fakeweb``` for a HTTP server, informing it to 'fake', or, in the test double vernacular - 'stub' - responses.

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

    HttpStub::Rake::ServerTasks.new(name: :some_server, port: 8001) # Generates 'start_some_server' task
```

### Stubbing Server Responses ###

### What is a stub? ###

A unit of configuration that matches an incoming request to the server to a response.

### What is a stub activator? ###

A unit of configuration that activates, or enables, a stub when a url is hit on the server.

#### Stub via API ####

```HttpStub::Configurer``` offers an API to configure a stub server via the class and instance methods ```stub_activator```, ```stub!``` and ```activate!```.
These methods issue HTTP requests to the server, configuring it's responses.  An example follows:

```ruby
    class AuthenticationService
        include HttpStub::Configurer

        server "my.stub.server.com" # Often localhost for automated test purposes
        port 8001 # The server post number

        # Register stub for POST "/"
        stub! "/", method: :post, response: { status: 200 }
        # Register stub for POST "/" when GET "/unavailable" request is made
        stub_activator "/unavailable", "/", method: :post, response: { status: 404 }

        def unavailable!
            activate!("/unavailable") # Activates the "/unavailable" stub
        end

        def deny_access_for!(username)
            # Registers another stub for POST "/" matching on headers and parameters
            stub!("/", method: :get,
                       headers: { api_key: "some_fixed_key" },
                       parameters: { username: username },
                       response: { status: 403 })
        end

    end
```

The ```stub!``` and ```stub_activator``` methods share the same signatures, expect a ```stub_activator``` accepts an
activation url as the first argument.

A stubs uri and parameter and header values accepted in the ```stub_activator``` and ```stub!``` methods can be
regular expressions:

```ruby
    stub! /prefix\/[^\/]*\/postfix/, method: :post, response: { status: 200 }

    stub_activator "/activate_this", /prefix\/[^\/]+\/postfix/,
                   method: :post,
                   headers: { api_key: /^some_.+_key$/ },
                   parameters: { username: /^user_.+/ },
                   response: { status: 200 }
```

The stubs known by the server can also be cleared via class methods ```clear_activators!``` and ```clear!```,
which clears stubs only.

These methods are often used on completion of tests to return the server to a known state:

```ruby
    let(:authentication_service) { AuthenticationService.new }

    # Returns server to post-initialize state
    after(:each) { authentication_service.reset! }

    describe "when the service is unavailable" do

        before(:each) { authentication_service.unavailable! }

        #...
```

##### Configurer Initialization ######

You must tell a Configurer when a server is running, otherwise operations will buffer and never be issued to the
server.

This can be done in one of two ways, via the ```initialize!``` or ```server_is_started!``` class methods.

The ```initialize!``` method has the benefit of:
* Flushing all pending requests
* Enabling the ```reset!``` class method, which efficiently returns the server to it's post-initialization state

A common use case is to start the server and ```initialize!``` in one process, for example before running acceptance
tests, and then ```reset!``` before each test runs:

```ruby
    task :acceptance => [:start_some_service, :cucumber]

    task :start_some_service => :start_some_server do
        SomeConfigurer.initialize! # Initialize the server prior to running any tests
    end
```

```ruby
    Before do                             # Before each acceptance test scenario
        SomeConfigurer.server_is_started! # Ensure operations are issued immediately
        SomeConfigurer.reset!             # Return to post-initialization state
    end
```

Take a look at the [http_server_manager gem]|(http://rubygems.org/gems/http_server_manager) should you be looking for a
simple way to start / stop / restart a ```http_stub``` server running as a separate process.

The ```HttpStub::Rake::ServerTasks``` also generates a task that initializes a server should a configurer be provided:

```ruby
    require 'http_stub/rake/task_generators'

    HttpStub::Rake::ServerTasks.new(name: :some_server, port: 8001, configurer: MyConfigurer) # Generates 'configure_some_server' task
```

#### Stub via HTTP requests ####

Alternatively, you can configure the ```http_stub``` server via direct HTTP requests.

To configure a stub response, POST to /stubs with the following JSON payload:

```javascript
    {
        "uri": "/some/path",
        "method": "some method",
        "headers": {
            "a_header": "a_value",
            "another_header": "another_value"
            ...
        },
        "parameters": {
            "a_param": "a_value",
            "another_param": "another_value"
            ...
        },
        "response": {
            "status": "200",
            "body": "Some body"
        }
    }
```

The stub uri, header values and parameter values can be regular expressions by prefixing them with ```regexp:```

```javascript
    {
        "uri": "regexp:/prefix/.+",
        "headers": {
            "a_header": "regexp:^some.+value$",
        },
        "parameters": {
            "a_param": "regexp:^some.+a_value$",
        }
    }
```

To configure a stub activator, POST to /stubs/activators with the following JSON payload:

```javascript
    {
        "activation_uri": "/some/activation/path",
        // remainder same as stub request...
    }
```

To activate a stub activator, GET the activation_uri.

DELETE to /stubs in order to clear configured stubs.
DELETE to /stubs/activators in order to clear configured stub activators.

### Request configuration rules ###

The **uri and method attributes are mandatory**.
Only subsequent requests matching these criteria will respond with the configured response.

The **headers attribute is optional**.
When included, requests containing headers matching these names and values will return the stub response.
Due to header name rewriting performed by Ruby Rack, header name matches are case-insensitive and consider underscores and hyphens to be synonymous.
The 'HTTP_' prefix added to the header names by Rack is removed prior to any comparison.
Requests containing additional headers will also match.

The **parameters attribute is optional**.
When included, requests containing parameters matching these names and values will return the stub response.
The name match is case sensitive.
Requests containing additional parameters will also match.

Stubs for **GET, POST, PUT, DELETE, PATCH and OPTIONS request methods are supported**.

**The most-recent matching configured stub request wins**.

### Informational pages ###

GET to /stubs/activators returns HTML with information about each configured activator, including activation links.
GET to /stubs returns HTML with information about each active stub, in top-down priority order.

Requirements
------------

* Ruby 1.9
* Rack server

Build Status
------------

[![Build Status](https://travis-ci.org/MYOB-Technology/http_stub.png)](https://travis-ci.org/MYOB-Technology/http_stub)
