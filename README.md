http_stub
=========

A Http Server replaying configured stub responses.

Guide
-----

* Configure responses via a POST to /stub with the following JSON payload:

> {
>   "uri": "/some/path",
>   "method": "some method",
>   "parameters": {
>     "a_key": "a_value",
>     "another_key": "another_value"
>     ...
>   },
>   "response": {
>     "status": "200",
>     "body": "Some body"
>   }
> }

* The uri and method attributes are mandatory.
  Only subsequent requests matching these criteria will respond with the configured response.

* The parameters attribute is optional.
  When included, requests with matching parameters will return the stub response.

* The most-recent configured stub request matching wins.

* Supported request types: GET, POST, PUT, DELETE, PATCH, OPTIONS

Requirements
------------

* Ruby 1.9.3
* Rack server
