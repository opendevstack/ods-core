#!/bin/sh

# check if ansible is already installed by using hash function
if hash ansible-playbook 2> /dev/null; then
        echo "ansible already installed"
else
        echo "installing ansible"
        yum install -y epel-release
        yum install -y ansible
fi
