#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
ansible-playbook -i inventories/dev playbooks/bitbucket-upgrade.yml --extra-vars "target_hosts=tag_hostgroup_bitbucket_test" --ask-vault-pass "$@"
cd -
