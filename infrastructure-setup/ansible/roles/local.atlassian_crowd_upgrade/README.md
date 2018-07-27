atlassian_crowd
=========

This role installs atlassian crowd and performs some basic configuration.
Unfortunately some steps are required in the graphical installer after first installation.

Role Variables
--------------

role variables and their defaults

``` yml
---
atlassian_crowd_version: 2.11.2

atlassian_crowd_baseurl: https://www.atlassian.com/software/crowd/downloads/binary/
atlassian_crowd_basedir: /opt/atlassian
atlassian_crowd_home: /srv/atlassian/crowd

atlassian_crowd_user: crowd
atlassian_crowd_uid: 10002
atlassian_crowd_group: crowd
atlassian_crowd_gid: 10002

atlassian_crowd_hibernate_dialect: org.hibernate.dialect.PostgreSQLDialect
atlassian_crowd_url: http://192.168.31.56:8095/crowd
atlassian_crowd_demo_url: http://192.168.31.56:8095/demo
atlassian_crowd_openidserver_url: http://192.168.31.56:8095/openidserver

atlassian_crowd_jdbc_url: "jdbc:postgresql://{{postgresql_host}}:{{postgresql_port}}/atlassian"

```

Dependencies
------------

Crowd requires a jdk installation.
This is not configured as a role dependency, but must be installed
seperately, see example playbook.

Example Playbook
----------------
``` yml
---
- hosts: tag_hostgroup_crowd
  roles:
  - role: williamyeh.oracle-java
    become: True
    java_version: 8
    java_subversion: 112
  - role: local.atlassian_crowd
---
