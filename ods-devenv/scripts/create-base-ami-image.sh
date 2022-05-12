#!/usr/bin/env bash

set -eu

echo "This script is in charge of configuring the base AMI image we use."
read -p "Continue (y/n) ?  " yn
if [ -z "$yn" ] || [ "y" != "$yn" ]; then
    echo "Exit"
    exit 0
fi

sudo yum update -y
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
sudo yum -y install git gitk iproute lsof
curl -LO https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-94.0.4606.81-1.x86_64.rpm
yum install -y google-chrome-stable-94.0.4606.81-1.x86_64.rpm
sudo yum install -y google-chrome-stable-94.0.4606.81-1.x86_64.rpm
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install xrdp
rm -f google-chrome-stable-94.0.4606.81-1.x86_64.rpm
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum -y install docker-ce-3:19.03.14-3.el7.x86_64
sudo yum install -y centos-release-openshift-origin311
sudo yum install -y origin-clients
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

sudo sed -i "s@.*PasswordAuthentication\ .*@PasswordAuthentication yes@g" /etc/ssh/sshd_config
sudo sed -i "s@.*ChallengeResponseAuthentication\ .*@ChallengeResponseAuthentication yes@g" /etc/ssh/sshd_config
sudo sed -i "s@.*GSSAPIAuthentication\ .*@GSSAPIAuthentication no@g" /etc/ssh/sshd_config
sudo sed -i "s@.*KerberosAuthentication\ .*@KerberosAuthentication no@g" /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl status sshd

sudo adduser openshift
echo -e "openshift\nopenshift" | sudo passwd openshift
sudo usermod -a -G wheel openshift
sed -i 's/%wheel\s*ALL=(ALL)\s*ALL/%wheel        ALL=(ALL)       NOPASSWD: ALL/g' /etc/sudoers

sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install firewalld git2u-all glances golang jq tree

