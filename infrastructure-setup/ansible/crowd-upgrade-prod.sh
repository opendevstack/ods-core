#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
ansible-playbook -i inventories/ec2 playbooks/crowd-upgrade.yml --extra-vars "target_hosts=tag_hostgroup_crowd" --ask-vault-pass "$@"
cd -
