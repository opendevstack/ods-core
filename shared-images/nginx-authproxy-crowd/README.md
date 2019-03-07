Crowd HTTP Auth proxy
=====================

Alpine Nginx OpenResty docker with Crowd HTTP Auth Lua module proxy enabled.

The docker is based on ods-core/shared-images/openresty-nginx. See its README for further functionalities ready to be used or new to be implemented.

Modsecurity is also ready to be used with default OWASP CRS rulesets, but disabled by default.
To enable it you need to set on 'WAF_MODSECURITY' to on (off by default) environment variable and it will be applied in nginx.conf.
For applying different custom configs you will need to load and replace with new modsecurity.conf and crs-setup.conf files.
You can also enable dynamic configuration and new functionalities through Lua nginx scripting. See more in openresty-nginx README.

Environment variables
---------------------

- SERVICE: the service to proxy to
- SERVER_SIGNATURE: the server name to be provided in the HTTP header
- WAF_MODSECURITY: off by default. Set to 'on' if WAF is required. See aforementioned Modsecurity topics in this readme file to understand implications of using it.
- CROWD_REALM_NAME: attribute required for all authentication schemes which issue a challenge
- CROWD_URL: the Crowd server service URL
- CROWD_SERVICE: the Crowd application name to connect to
- CROWD_PASSWORD: the Crowd application password to connect to
