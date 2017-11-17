http_stub
=========

```http_stub``` is a [service virtualization](https://en.wikipedia.org/wiki/Service_virtualization) tool.<br/>
It provides a HTTP server that is configurable on-the-fly to [stub](https://en.wikipedia.org/wiki/Test_stub) responses
to matched requests.

```http_stub``` has been primarily designed to aid automated and exploratory testing for API **consumers**:
* By providing tools to simulate a producer API and change its responses on-the-fly 
* By aiming to provide tools that validate the simulation is true to the producer

Status
------

[![Build Status](https://travis-ci.org/MYOB-Technology/http_stub.png)](https://travis-ci.org/MYOB-Technology/http_stub)
[![Gem Version](https://badge.fury.io/rb/http_stub.png)](http://badge.fury.io/rb/http_stub)
[![Code Climate](https://codeclimate.com/github/MYOB-Technology/http_stub/badges/gpa.svg)](https://codeclimate.com/github/MYOB-Technology/http_stub)
[![Test Coverage](https://codeclimate.com/github/MYOB-Technology/http_stub/badges/coverage.svg)](https://codeclimate.com/github/MYOB-Technology/http_stub/coverage)
[![Dependency Status](https://gemnasium.com/MYOB-Technology/http_stub.png)](https://gemnasium.com/MYOB-Technology/http_stub)

Design
------

```http_stub``` is composed of two parts:
* A HTTP server (Sinatra) that replays known responses when an incoming request matches defined criteria.  The server 
  is run in a dedicated - external - process to the system under test to better simulate the real architecture. 
* A Ruby DSL used to configure the server known as a ```Configurator```

Usage
-----

## Step 1: Define The Server Configuration ##

To simulate a response from an authentication service, let's stub the service and respond to its login endpoint by
either granting or denying access:

```ruby
module AuthenticationService

  class Configurator
    include HttpStub::Configurator

    login_template = stub_server.endpoint_template { match_requests(uri: "/login", method: :post) }

    login_template.add_scenario!("Grant access", status: 200)
    login_template.add_scenario!("Deny access",  status: 401)
  end

end
```

## Step 2: Start The Server ##

Define tasks to manage the servers lifecycle:

```ruby
  require 'http_stub/rake/task_generators'

  configurator = AuthenticationService::Configurator
  configurator.stub_server.port = 8000

  HttpStub::Rake::ServerDaemonTasks.new(name: :authentication_service, configurator: configurator)
```

Then start the server:

```
some_host:some_path some_user$ rake authentication_service:start
authentication_service started on localhost:8000
```

Congratulations, your server is now running on `localhost:8000`!

## Step 3: Activate Scenarios On-The-Fly ##

Now we can activate scenarios as needed.

### Activating Scenarios Via Code ###

Within automated tests you'll often need to activate a scenario:

```ruby

  let(:stub_client) { HttpStub::Client.new("http://localhost:8000") }

  context "when access is granted" do

    before(:example) { stub_client.activate!("Grant access") }

    ...

  end
```

### Activating Scenarios Via The Admin UI ###

The server has an admin UI accessible on ```http://localhost:8000/http_stub```:

![http://localhost:8000/http_stub/](examples/resources/admin_ui_homepage.png "Admin UI Homepage")

It allows scenarios to be listed and activated on-the-fly:

![http://localhost:8000/http_stub/scenarios/](examples/resources/admin_ui_scenarios.png "Admin UI Scenarios")

More Information
----------------

```http_stub``` can [match requests](https://github.com/MYOB-Technology/http_stub/wiki/Stub-Request-Matching) against a
variety of criteria, including JSON schemas, and can
[respond](https://github.com/MYOB-Technology/http_stub/wiki/Stub-Responses) with arbitrary content including files and
values interpolated from the matching request.

See the [wiki](https://github.com/MYOB-Technology/http_stub/wiki) for more usage details and examples.

For those using [Docker](https://www.docker.com),
[http_stub_docker](https://github.com/MYOB-Technology/http_stub_docker) provides Rake tasks that simplify creating,
validating and distributing Docker containers for stubs. 

Installation
------------

In your Gemfile include:

```ruby
    gem 'http_stub'
```

Requirements
------------

* Ruby >= 2.2.2 (see the [CHANGELOG](https://github.com/MYOB-Technology/http_stub/blob/master/CHANGELOG.md) for older versions supporting prior Rubies)
* A Rack server

Alternatives and Comparisons
----------------------------

### [Pact](https://github.com/realestate-com-au/pact)
Facilitates consumer driven contracts by allowing consumers to define a contract that is shared with and verified by producers.

In comparison ```http_stub```:
* Supports on-the-fly changes to responses to aid exploratory testing and demonstrations.
* Supports specification based contracts in addition to example based contracts.  Incoming requests can be matched through the use of clauses such as regular expressions and JSON schema definitions.
* See comparison with ```http-stub-server``` for more highlights.

```http_stub``` can be used for Consumer & Producer based contract verification.
For more information, see the dedicated [Slide Deck](https://docs.google.com/presentation/d/18iikw5rXuHNt7TxmAuiak9kFXR3wmObMMB1jlqrrwbQ/edit?usp=sharing) & [Wiki Page](https://github.com/MYOB-Technology/http_stub/wiki/Contract-Based-Testing-Recommendations).

### [VCR](https://github.com/vcr/vcr)
Records requests and responses onto 'cassettes'.  Replays responses in-process by mocking HTTP libraries in use.

In comparison ```http_stub```:
* Relies on an external HTTP server and does not effect HTTP libraries in use.
* Facilitates test-first practice by not relying on real integrations being recorded and pre-existing.
* Can make it easier to write and alter requests and responses by not having to alter or re-record cassettes / recordings.

### [http-stub-server](https://github.com/Sensis/http-stub-server)
Similar in spirit, implemented in Java and comes with Java and Ruby clients.

In comparison ```http_stub```:
* Has [session support](https://github.com/MYOB-Technology/http_stub/wiki/Stub%20Sessions) to facilitate parallel test execution.
* Has the concept of [scenarios](https://github.com/MYOB-Technology/http_stub/wiki/Scenarios) that allow on-the-fly changes to responses.  This aids automated testing, exploratory testing and demonstrations.
* Supports a wider range of [matching rules](https://github.com/MYOB-Technology/http_stub/wiki/Stub-Request-Matching) and can match requests against JSON schemas.
* Supports references to request headers and parameters in responses.
* Supports multi-part file responses.
* Allows cross-origin request support to be enabled easily.
* Allows a match to trigger the registration of other ```stubs``` to simulate state changes in the provider.
* Has [diagnostic pages](https://github.com/MYOB-Technology/http_stub/wiki/Diagnostic-Pages) to interrogate the state of the stub, trace requests to responses, and activate scenarios on-the-fly.
* Has an elegant [Ruby DSL](https://github.com/MYOB-Technology/http_stub/wiki/The-Configurator-DSL) that aids in keeping requests and responses DRY.

### [HTTParrot](https://github.com/abrandoned/httparrot), [Rack Stubs](https://github.com/featurist/rack-stubs), [mock_server](https://github.com/unixcharles/mock_server)
These are similar in spirit, implemented in Ruby, but have limited functionality and have been discontinued.
