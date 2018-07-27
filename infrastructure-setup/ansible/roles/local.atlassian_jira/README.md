local.atlassian_jira
=========

This role installs or upgrades Atlassian Jira. It uses the installer provided by
atlassian. The installer basically does the following

- install the package
- create users
- create services
- manage permissions
- upgrade existing installations (including backup of filesystem and
  configuration migration)
- adjust JVM settings to [support the eazyBI plugin](https://docs.eazybi.com/display/EAZYBIJIRA/Installation+and+setup#Installationandsetup-PostgreSQL)

For more information on the unattended installer see: https://confluence.atlassian.com/adminjiraserver073/unattended-installation-861253035.html

In addition to the installer, the role also configures the database connection
and the license

Requirements
------------

none

Role Variables
--------------

role variables and their defaults:

``` yml
atlassian_jira_version: 7.3.6

# installation directory
atlassian_jira_installation_dir: /opt/atlassian/jira

# data directory of jira
# see https://confluence.atlassian.com/adminjiraserver073/jira-application-home-directory-861253888.html
atlassian_jira_home: /srv/atlassian/jira

# is this an upgrade of an existing installation?
atlassian_jira_upgrade: false

atlassian_jira_jdbc_url: jdbc:postgresql://localhost:5432/atlassian
atlassian_jira_jdbc_password: jira
```

Dependencies
------------

none

Example Playbook
----------------

  - hosts: servers
      roles:
         - role: local.atlassian_jira
           atlassian_jira_version: 7.3.6


License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
