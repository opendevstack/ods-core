Alpine Nginx OpenResty + Lua + ModSecurity WAF base image
=======================================================

Nginx based project with Lua enablement and WAF module integrated (default 'off'). Ready for scripting/developing API gateways.

Modsecurity is also ready to be used with default OWASP CRS rulesets, but disabled by default.
To enable it you need to set on 'WAF_MODSECURITY' to on (off by default) environment variable and it will be applied in nginx.conf.
For applying different custom configs you will need to load and replace with new modsecurity.conf and crs-setup.conf files.

You can also enable dynamic configuration and new functionalities through Lua nginx scripting. See more in openresty-nginx README.

There is no usage of separate nginx virtual host file config since one needs to have the server statement inside the http statement in nginx.conf for loading environment variables in such statement. Therefore, 'server' statement config must go inside nginx.conf inside 'http' statement config.

NGINX MODULES
-------------

- [Modsecurity](https://github.com/SpiderLabs/ModSecurity/wiki): Modsecurity module with the OWASP CSR default entries. Enable or disable (default is disabled) it by setting environment variable WAF_MODSECURITY (values: on, off). Components being used:

    --> ModSecurity library [documentation](https://github.com/SpiderLabs/ModSecurity/blob/v3/master/README.md)

    --> Nginx ModSecurity connector [documentation](https://github.com/SpiderLabs/ModSecurity-nginx)

Lua MODULES
-----------

- Crowd HTTP Auth: Crowd REALM Auth Lua module. Check shared-images/nginx-authproxy-crowd to how to use it.

See lua/ folder for further examples ready to be used

VERSIONING
----------

In order to upgrade to newer versions just change the related *_VERSION values in the base Dockerfile image. Current managed versions:
- RESTY_IMAGE_BASE="alpine"
- RESTY_IMAGE_TAG="3.8"
- NGINX_VERSION="1.13.6"
- MODSECURITY_VERSION="3.0.0"
- MODSECURITY_NGINX_VERSION="1.0.0"
- OWASP_MODSECURITY_CRS_VERSION="3.0.2"
- RESTY_VERSION="1.13.6.2"
- RESTY_OPENSSL_VERSION="1.0.2p"
- RESTY_PCRE_VERSION="8.42"


Testing WAF security and Nginx performance
------------------------------------------

- Security:
```
nikto -h http://<host:port>
```

- Performance:
```
 siege --concurrent 100 --reps 10 http://<host:port>
```
