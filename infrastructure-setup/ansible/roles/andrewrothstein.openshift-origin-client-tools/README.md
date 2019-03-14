andrewrothstein.openshift-origin-client-tools
=========
[![Build Status](https://travis-ci.org/andrewrothstein/ansible-openshift-origin-client-tools.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-openshift-origin-client-tools)

Installs [OpenShift Origin Client Tools](https://github.com/openshift/origin) include the oc CLI.

Requirements
------------

See [meta/main.yml](meta/main.yml)

Role Variables
--------------

See [defaults/main.yml](defaults/main.yml)

Dependencies
------------

See [meta/main.yml](meta/main.yml)

Example Playbook
----------------

```yml
- hosts: servers
  roles:
    - andrewrothstein.openshift-origin-client-tools
```

License
-------

MIT

Author Information
------------------

Andrew Rothstein <andrew.rothstein@gmail.com>
