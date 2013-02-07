http_stub
=========

A Http Server replaying configured stub responses.

Guide
-----

# Configure responses via a POST to /stub with the following JSON payload:

> {
>   "uri": "/some/path",
>   "method": "get",
>   "response": {
>     "status": "200",
>     "body": "Hello World"
>   }
> }

# Supported request types: GET, POST, PUT, DELETE, PATCH, OPTIONS
