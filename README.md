http_stub
=========

```fakeweb``` for a HTTP server, informing it to 'fake', or, in the test double vernacular - 'stub' - responses.

Status
------------

[![Build Status](https://travis-ci.org/MYOB-Technology/http_stub.png)](https://travis-ci.org/MYOB-Technology/http_stub)
[![Gem Version](https://badge.fury.io/rb/http_stub.png)](http://badge.fury.io/rb/http_stub)
[![Code Climate](https://codeclimate.com/github/MYOB-Technology/http_stub/badges/gpa.svg)](https://codeclimate.com/github/MYOB-Technology/http_stub)
[![Test Coverage](https://codeclimate.com/github/MYOB-Technology/http_stub/badges/coverage.svg)](https://codeclimate.com/github/MYOB-Technology/http_stub/coverage)
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

To simulate common respones from an authentication service, let's stub a service which will respond to a login request
by either granting or denying access:

```ruby
class AuthenticationServiceConfigurer
  include HttpStub::Configurer

  stub_server.port = 8000

  login_template = stub_server.endpoint_template { match_requests(uri: "/login", method: :post) }

  login_template.add_scenario!("grant_access", status: 200)
  login_template.add_scenario!("deny_access",  status: 401)
  
end
```

Now we can initialize the service and activate the scenarios as needed.

```ruby
AuthenticationServiceConfigurer.initialize!
AuthenticationServiceConfigurer.stub_server.activate!("grant_access")
```

Navigating to the locally running stub server (e.g. ```http://localhost:8000/http_stub/scenarios```) reveals the scenarios
which we can activate manually by clicking the links.

![http://localhost:8000/http_stub/scenarios/](examples/resources/authentication_service_scenarios.png "Scenarios Diagnostic Page")

```http_stub``` can match requests against a variety of criteria, including JSON schemas, and can respond with arbitrary
content including files.

See the [wiki](https://github.com/MYOB-Technology/http_stub/wiki) for more usage details and examples.

Installation
------------

In your Gemfile include:

```ruby
    gem 'http_stub'
```

Requirements
------------

* Ruby >= 1.9.3
* A Rack server
