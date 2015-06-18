** 0.12.0 **

Daemon renamed to ServerDaemon for clarity.

** 0.16.0 **

Added scenarios.
Deprecated stub activators.

Breaking change: Activator paths replaced by activator names.  Calls to ```stub_activator`` and ```activate!``` must 
no longer have '/' prefix.
 
 ** 0.17.0 **
 
Added request body matching via exact match, regex match and JSON schema validation match.

Breaking change: ```Configurer``` host, port and base_uri related methods must now be accessed via the
```stub_server```.
