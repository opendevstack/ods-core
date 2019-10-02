#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
ansible-playbook -i inventories/ec2 playbooks/jira-upgrade.yml --extra-vars "target_hosts=tag_hostgroup_jira" --ask-vault-pass "$@"
ansible-playbook -i inventories/ec2 playbooks/jira_enable_sso.yml --extra-vars "target_hosts=tag_hostgroup_jira" --ask-vault-pass "$@"
cd -
