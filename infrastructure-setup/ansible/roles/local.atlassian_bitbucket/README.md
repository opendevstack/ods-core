Ansible Role: Atlassian Bitbucket
=========

This role installs or upgrades atlassian bitbucket. It uses the installer
provided by Atlassian.

Role Variables
--------------

role variables and their defaults

``` yml
---
# version of bitbucket to install
atlassian_bitbucket_version: 4.14.3

# installation directory
atlassian_bitbucket_basedir: /opt/atlassian/bitbucket
# data directory of bitbucket (repositories, logs, configuration)
# see https://confluence.atlassian.com/bitbucketserver/bitbucket-server-home-directory-776640890.html
atlassian_bitbucket_home: /srv/atlassian/bitbucket

#The display name for the Bitbucket Server application.
atlassian_bitbucket_display_name: Bitbucket
# the base url (used for links in notifications)
atlassian_bitbucket_base_url: http://127.0.0.1:7990

# the bitbucket license (should be overwritten and encrypted)
atlassian_bitbucket_license:

# connection to bitbucket database
atlassian_bitbucket_jdbc_url: jdbc:postgresql://localhost:5432/bitbucket
atlassian_bitbucket_jdbc_user: bitbucket
# the password for the database (should be overwritten and encrypted)
atlassian_bitbucket_jdbc_password: bitbucket
# is bitbucket secured via https with a proxy
atlassian_bitbucket_secure: false
# if bitbucket is behind a proxy, provide the endpoint name and port
atlassian_bitbucket_proxy_port: 443
# if empty, no proxy is used
atlassian_bitbucket_proxy_name:
# enable sso integration with atlassian crowd
atlassian_bitbucket_sso_enabled: false
```

Dependencies
------------

none 

Example Playbook
----------------

    - hosts: servers
      roles:
         - role: local.atlassian_bitbucket
           atlassian_bitbucket_version: 4.13.4

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
