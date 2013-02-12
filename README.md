http_stub
=========

A Http Server replaying configured stub responses.

Guide
-----

* Configure responses via a POST to /stub with the following JSON payload:

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

    * The uri and method attributes are mandatory.
      Only subsequent requests matching these criteria will respond with the configured response.
    * The parameters attribute is optional.
      When included, requests with matching parameters will return the stub response.
    * The most-recent matching configured stub request wins.
    * Stubs for GET, POST, PUT, DELETE, PATCH, OPTIONS request methods are supported.

* Clear all configured responses via a DELETE to /stubs.

* Http::Stub::Client is a Ruby API on top of the HTTP requests, providing two methods: ```stub!``` and ```clear!```

```ruby
    class AuthenticationService
        include Http::Stub::Client

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

* Includes a Rake Task generator, generating a task that starts a stub server:

```ruby
    require 'http/stub/start_server_rake_task'
    Http::Stub::StartServerRakeTask.new(name: :some_server, port: 8080) # generates start_some_server task
```

Requirements
------------

* Ruby 1.9.3
* Rack server
