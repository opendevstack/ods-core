#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR
ansible-playbook -i inventories/dev playbooks/jira-upgrade.yml --extra-vars "target_hosts=tag_hostgroup_jira_test" --ask-vault-pass "$@"
ansible-playbook -i inventories/dev playbooks/jira_enable_sso.yml --extra-vars "target_hosts=tag_hostgroup_jira_test" --ask-vault-pass "$@"
cd -
