http_stub
=========

A HTTP Server replaying configured stub responses.

Installation
------------

gem install http_stub

Usage
-----

### Starting Server ###

Generate a rake task that starts a stub server:

```ruby
    require 'http_stub/start_server_rake_task'

    HttpStub::StartServerRakeTask.new(name: :some_server, port: 8080) # Generates start_some_server task
```

### Stubbing Server Responses ###

#### Stub via Ruby API ####

HttpStub::Client is a Ruby API that issues requests to the stub server via two methods: ```stub!``` and ```clear!```

```ruby
    class AuthenticationService
        include HttpStub::Client

        server "stub.authenticator.com"
        port 8001

        def deny_access
            stub!("/", method: :get, response: { status: 403 }) # Registers a stub response
        end

    end
```

```ruby
    before(:all) do
        @oauth_service = OAuthService.new
    end

    after(:each) do
        @oauth_service.clear! # Removes all stub responses
    end

    describe "when access is granted" do

        before(:each) { @oauth_service.grant_access }

    end
```

#### Stub via HTTP requests ####

POST to /stub with the following JSON payload:

```javascript
    {
        "uri": "/some/path",
        "method": "some method",
        "parameters": {
            "a_key": "a_value",
            "another_key": "another_value"
            ...
        },
        "response": {
            "status": "200",
            "body": "Some body"
        }
    }
```

DELETE to /stubs in order to clear configured stubs.

### Request configuration rules ###

The **uri and method attributes are mandatory**.
Only subsequent requests matching these criteria will respond with the configured response.

The **parameters attribute is optional**.
When included, requests with matching parameters will return the stub response.

Stubs for **GET, POST, PUT, DELETE, PATCH, OPTIONS request methods are supported**.

**The most-recent matching configured stub request wins**.

Requirements
------------

* Ruby 1.9.3
* Rack server
