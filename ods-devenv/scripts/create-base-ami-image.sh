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
sudo yum -y install git gitk iproute lsof xrdp tigervnc-server remmina firewalld git2u-all glances golang jq tree htop etckeeper

curl -LO https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-94.0.4606.81-1.x86_64.rpm
sudo yum install -y google-chrome-stable-94.0.4606.81-1.x86_64.rpm
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
sudo sed -i 's/%wheel\s*ALL=(ALL)\s*ALL/%wheel        ALL=(ALL)       NOPASSWD: ALL/g' /etc/sudoers

sudo usermod -a -G docker openshift

# etckeeper
cd /etc/
sudo etckeeper init
sudo etckeeper commit -m "Initial commit"

# GUI:
sudo yum groupinstall -y "MATE Desktop"
sudo yum groups -y install "GNOME Desktop"

# GUI access via XRDP
sudo firewall-cmd --add-port=3389/tcp --permanent
sudo firewall-cmd --add-port=3350/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl enable xrdp
sudo chcon --type=bin_t /usr/sbin/xrdp
sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
sudo sed -i 's/^\s*ListenAddress=127.0.0.1\s*$/ListenAddress=0.0.0.0/g' /etc/xrdp/sesman.ini

# JDK
cat <<EOF > /tmp/adoptopenjdk.repo
[AdoptOpenJDK]
name=AdoptOpenJDK
baseurl=http://adoptopenjdk.jfrog.io/adoptopenjdk/rpm/centos/7/$(uname -m)
enabled=1
gpgcheck=1
gpgkey=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public
EOF

sudo mv /tmp/adoptopenjdk.repo /etc/yum.repos.d/adoptopenjdk.repo

sudo yum -y install adoptopenjdk-8-hotspot adoptopenjdk-11-hotspot adoptopenjdk-8-hotspot-jre adoptopenjdk-11-hotspot-jre

sudo sed -i 's/.*crypt_level=.*/crypt_level=none/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/.*max_bpp=.*/max_bpp=24/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/.*xserverbpp=.*/xserverbpp=24/g' /etc/xrdp/xrdp.ini


echo " "
echo " "
echo "Please remember after running all this scripts you need to reboot the AMI image, so users and group changes are loaded."
echo "To do it, run (for example) shutdown -r now "
echo " "
echo " "
