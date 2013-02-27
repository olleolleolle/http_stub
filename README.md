http_stub
=========

A HTTP Server replaying configured stub responses.

Installation
------------

In your Gemfile include:

```ruby
    gem 'http_stub'
```

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

HttpStub::Configurer is a Ruby API that configures the stub server via the class method ```stub_alias``` and instance methods ```stub!```, ```activate!``` and ```clear!```

```ruby
    class AuthenticationService
        include HttpStub::Configurer

        server "stub.authenticator.com"
        port 8001

        stub_alias "/unavailable", "/", method: :get, response: { status: 404 } # Register a stub for "/" when GET "/unavailable" request is made

        def unavailable!
            activate!("/unavailable") # Activates the "/unavailable" alias
        end

        def deny_access_for!(username)
            stub!("/", method: :get, parameters: { username: username }, response: { status: 403 }) # Registers a stub response
        end

    end
```

**Important**: Once a server is running, initialize a Configurer via the ```initialize!``` class method.

```ruby
    AuthenticationService.initialize!
```

```ruby
    before(:all) do
        @oauth_service = OAuthService.new
    end

    after(:each) do
        @oauth_service.clear! # Removes all stub responses, but retains aliases
    end

    describe "when access is granted" do

        before(:each) { @oauth_service.grant_access }

    end
```

#### Stub via HTTP requests ####

To configure a stub, POST to /stubs with the following JSON payload:

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

To configure an alias, POST to /stubs/aliases with the following JSON payload:

```javascript
    {
        "alias_uri": "/some/alias/path",
        # remainder same as stub request...
    }
```

To activate an alias, GET the alias_uri.

DELETE to /stubs in order to clear configured stubs.

DELETE to /stubs/aliases in order to clear configured aliases.

### Request configuration rules ###

The **uri and method attributes are mandatory**.
Only subsequent requests matching these criteria will respond with the configured response.

The **parameters attribute is optional**.
When included, requests containing parameters matching these names and values will return the stub response.
Requests that contain additional parameters will also match.

Stubs for **GET, POST, PUT, DELETE, PATCH, OPTIONS request methods are supported**.

**The most-recent matching configured stub request wins**.

### Informational pages ###

GET to /stubs/aliases returns HTML with information about each configured alias, including activation links.

Requirements
------------

* Ruby 1.9
* Rack server
