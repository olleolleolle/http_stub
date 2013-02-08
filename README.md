http_stub
=========

A Http Server replaying configured stub responses.

Guide
-----

* Configure responses via a POST to /stub with the following JSON payload:

> {
>   "uri": "/some/path",
>   "method": "some method",
>   "response": {
>     "status": "200",
>     "body": "Some body"
>   }
> }

* Supported request types: GET, POST, PUT, DELETE, PATCH, OPTIONS

Requirements
------------

* Ruby 1.9.3
* Rack server
