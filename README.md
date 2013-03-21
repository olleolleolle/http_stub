http_stub
=========

```fakeweb``` for a HTTP server, informing it to 'fake', or, in the test double vernacular - 'stub' - responses.

Motivation
----------

Need to simulate a HTTP service with which your application integrates?  Enter ```http_stub```.

```http_stub``` is similar in motivation to the ```fakeweb``` gem, although ```http_stub``` provides a separately running HTTP process whose responses can be faked / stubbed.

```http_stub``` appears to be very similar in purpose to the ```HTTParrot``` gem, although that appears to be inactive.

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

    HttpStub::Rake::StartServerTask.new(name: :some_server, port: 8001) # Generates 'start_some_server' task
```

### Stubbing Server Responses ###

#### Stub via API ####

HttpStub::Configurer is an API that configures the stub server via the class and instance methods ```stub_activator```, ```stub!``` and ```activate!```.
These methods issue HTTP requests to a ```http_stub``` server to configure it's responses.  An example follows:

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

Once a server is running, you must initialize it via the Configurer's ```initialize!``` class method:

```ruby
    AuthenticationService.initialize!
```

This informs the Configurer that the ```http_stub``` server is able to accept HTTP requests.

The state of the ```http_stub``` server can be cleared via class method ```clear_activators!``` and instance method ```clear!```, which clears stubs only.
These are often used on completion of tests to return the server to it's original state:

```ruby
    let(:authentication_service) { AuthenticationService.new }

    # Removes all stub responses, but retains activators
    after(:each) { authentication_service.clear! }

    describe "when the service is unavailable" do

        before(:each) { authentication_service.unavailable! }

        #...
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
