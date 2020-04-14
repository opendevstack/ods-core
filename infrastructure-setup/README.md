# OpenDevStack Infrastructure
The infrastructure setup is meant to help setting up a local OpenDevStack runtime environment.

To start a local setup, run
```
./setup-local.environment.sh
```

After you have configured the atlassian tools, proceed with
```
./prepare-local-environment.sh
```

If you want to setup the stack on a remote environment, you will have to amend the shell scripts and 
the inventories to match your requirements. 

## Ansible Provisioning
The provision via ansible has to be done at the ansible controller. This has only to be done manually, 
if you didn't use the shell scripts. 

### Prepare ansible controller
To prepare ansible controller
```
ansible-playbook -v -i inventories/dev playbooks/ansible-controller.yml --ask-vault
```

### Install base and additional packages

```
ansible-playbook -v -i inventories/dev playbooks/base_packages_and_config.yml --ask-vault
```

### Prepare ansible managed nodes

```
ansible-playbook -v -i inventories/dev playbooks/ansible_managed.yml --ask-vault
```

### Local Postgres Setup

Local testing requires a running postgres instance.

```
ansible-playbook -v -i inventories/dev playbooks/postgresql.yml --ask-vault
```

### Schema setup
To setup the required database schemas on the postgresql instance

```
ansible-playbook -v -i inventories/dev playbooks/schemas.yml --ask-vault
```


### Crowd Setup

TODO: service is not yet automatically started at first deployment.

Downloading and Configuring as service

```
ansible-playbook -v -i inventories/dev playbooks/crowd.yml --ask-vault
```

### Bitbucket Setup

```
ansible-playbook -v -i inventories/dev playbooks/bitbucket.yml --ask-vault
```

### Jira Setup

```
ansible-playbook -v -i inventories/dev playbooks/jira.yml --ask-vault
```

### Confluence Setup
```
ansible-playbook -v -i inventories/dev playbooks/confluence.yml --ask-vault
```
