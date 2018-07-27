atlassian_confluence
=========

This role installs atlassian confluence and performs some basic configuration.
Unfortunately some steps are required in the graphical installer after first installation.

Role Variables
--------------

role variables and their defaults

``` yml
---
atlassian_confluence_version: 6.1.3
# installation directory
atlassian_confluence_installation_dir: /opt/atlassian/confluence

# data directory of confluence
# see https://confluence.atlassian.com/doc/confluence-home-and-other-important-directories-590259707.html
atlassian_confluence_home: /srv/atlassian/confluence

# is this an upgrade of an existing installation?
atlassian_confluence_upgrade: false

# the confluence jdbc connection url
atlassian_confluence_jdbc_url: "jdbc:postgresql://{{postgresql_host}}:{{postgresql_port}}/atlassian?currentSchema=confluence"

# proxy name for the application, should only be set in production environment, see group_vars
atlassian_confluence_proxy_name: ""

```

Dependencies
------------

Confluence requires a jdk installation.
This is not configured as a role dependency, but must be installed
seperately, see example playbook.

Example Playbook
----------------
``` yml
---
- hosts: tag_hostgroup_confluence
  roles:
  - role: williamyeh.oracle-java
    become: True
    java_version: 8
    java_subversion: 112
  - role: local.atlassian_confluence
---
