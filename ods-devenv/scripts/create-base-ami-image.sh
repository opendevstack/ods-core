#!/usr/bin/env bash

set -eu

echo " "
echo "Pre-Usage:  "
echo "---------- "
echo "$ sudo yum -y install epel-release "
echo "$ sudo yum -y install curl jq"
echo "$ base64 --v ; jq --version ; curl --version "
echo "$ curl -sSL "https://api.github.com/repos/opendevstack/ods-core/contents/ods-devenv/scripts/create-base-ami-image.sh?ref=experimental" | jq -r ".content" | base64 --decode > create-base-ami-image.sh "
echo "$ chmod +x create-base-ami-image.sh "
echo "$ ./create-base-ami-image.sh [buildBot] "
echo " "
echo "This script is in charge of configuring the base AMI image we use."
read -p "Continue (y/n) ?  " yn
if [ -z "$yn" ] || [ "y" != "$yn" ]; then
    echo "Exit"
    exit 0
fi

function general_configuration() {
    sudo yum update -y || true
    sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm || true
    sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm || true
    sudo yum -y install git iproute lsof git2u-all glances golang jq tree || true
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || true
    sudo yum -y install docker-ce-3:19.03.14-3.el7.x86_64 || true

    sudo sed -i "s@.*PasswordAuthentication\ .*@PasswordAuthentication yes@g" /etc/ssh/sshd_config
    sudo sed -i "s@.*ChallengeResponseAuthentication\ .*@ChallengeResponseAuthentication yes@g" /etc/ssh/sshd_config
    sudo sed -i "s@.*GSSAPIAuthentication\ .*@GSSAPIAuthentication no@g" /etc/ssh/sshd_config
    sudo sed -i "s@.*KerberosAuthentication\ .*@KerberosAuthentication no@g" /etc/ssh/sshd_config
    sudo systemctl restart sshd 
    sudo systemctl status sshd

    # JDK
    rm -fv /tmp/adoptopenjdk.repo || echo "ERROR: Could not remove file /tmp/adoptopenjdk.repo "
    echo "[AdoptOpenJDK]" >> /tmp/adoptopenjdk.repo
    echo "name=AdoptOpenJDK" >> /tmp/adoptopenjdk.repo
    echo "baseurl=http://adoptopenjdk.jfrog.io/adoptopenjdk/rpm/centos/7/$(uname -m)" >> /tmp/adoptopenjdk.repo
    echo "enabled=1" >> /tmp/adoptopenjdk.repo
    echo "gpgcheck=1" >> /tmp/adoptopenjdk.repo
    echo "gpgkey=https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public" >> /tmp/adoptopenjdk.repo

    rm -fv /etc/yum.repos.d/adoptopenjdk.repo
    sudo mv -vf /tmp/adoptopenjdk.repo /etc/yum.repos.d/adoptopenjdk.repo

    # No more in use: adoptopenjdk-8-hotspot adoptopenjdk-8-hotspot-jre
    sudo yum -y install adoptopenjdk-11-hotspot  adoptopenjdk-11-hotspot-jre || true
    sudo yum -y remove java-1.7.0-openjdk java-1.7.0-openjdk-headless \
                       java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-headless.x86_64 \
                       java-11-openjdk.x86_64 java-11-openjdk-headless.x86_64 || true
    yum list installed | grep -i '\(openjdk\|jdk\|java\)'
}

function permissions_fixes() {
    local PENDING="false"
    grep -i openshift /etc/passwd || PENDING="true"
    if [ "true" == "${PENDING}" ] ; then
        sudo adduser openshift
        echo -e "openshift\nopenshift" | sudo passwd openshift
    fi

    PENDING="false"
    grep -i openshift /etc/group | grep -i wheel || PENDING="true"
    if [ "true" == "${PENDING}" ] ; then
        sudo usermod -a -G wheel openshift
    fi

    PENDING="false"
    sudo grep -v "^\s*#" /etc/sudoers | grep -i "wheel" | grep -i "nopasswd" || PENDING="true"
    if [ "true" == "${PENDING}" ] ; then
        sudo sed -i 's/%wheel\s*ALL=(ALL)\s*ALL/%wheel        ALL=(ALL)       NOPASSWD: ALL/g' /etc/sudoers
    fi

    PENDING="false"
    grep -i openshift /etc/group | grep -i docker || PENDING="true"
    if [ "true" == "${PENDING}" ] ; then
        sudo usermod -a -G docker openshift
    fi
}

function configuration_extras() {

    # Tools not needed in buildBot
    sudo yum -y install tigervnc-server remmina firewalld gitk htop etckeeper

    # etckeeper
    if [ ! -d /etc/.git ]; then
        cd /etc/
        sudo etckeeper init
        sudo etckeeper commit -m "Initial commit"
    else
        echo "WARNING: git repository in etc folder has been created before."
    fi

    # OCP 3
    sudo yum install -y centos-release-openshift-origin311
    sudo yum install -y origin-clients
    sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

    # GUI:
    sudo yum groupinstall -y "MATE Desktop" || echo "ERROR: Could not install mate desktop"
    sudo yum groups -y install "GNOME Desktop" || echo "ERROR: Could not install gnome desktop"

    # Google Chrome
    curl -LO https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-94.0.4606.81-1.x86_64.rpm
    sudo yum install -y google-chrome-stable-94.0.4606.81-1.x86_64.rpm
    rm -f google-chrome-stable-94.0.4606.81-1.x86_64.rpm

}

function setup_xrdp() {
    sudo yum -y install automake libtool libXaw-devel xorg-x11-server-devel xrdp-devel nasm yasm libXfont-devel \
                libXfont libXfont2 libXfont2-devel x11vnc pam-devel libXrandr-devel lame-devel lame-libs fuse \
                fuse-devel fuse-libs pixman pixman-devel turbojpeg turbojpeg-devel \
                openjpeg openjpeg-devel openjpeg-libs libjpeg* imlib2-devel imlib2

    mkdir -pv /tmp/xrdp-srcs
    cd /tmp/xrdp-srcs
    git clone https://github.com/neutrinolabs/xrdp.git
    cd xrdp/
    git clone https://github.com/neutrinolabs/xorgxrdp.git

    sudo yum -y remove xorgxrdp xrdp xrdp-selinux || true

    cd xorgxrdp
    ./bootstrap
    ./configure --prefix=/usr
    make
    sudo make install
    cd ..

    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
    ./bootstrap
    ./configure --enable-fuse --enable-mp3lame --enable-jpeg --enable-imlib2 --enable-tjpeg --enable-pixman --enable-painter --prefix=/usr

    export CFLAGS="-g -O2 -Wall -Wwrite-strings";  make --environment-overrides
    sudo make install

    echo -e "/usr/lib64/xorg/modules\n/usr/lib64/xorg/modules/input\n/usr/lib64/xorg/modules/drivers" \
        | sudo tee -a /etc/ld.so.conf.d/xorgxrdp.conf
    sudo ldconfig

    sudo systemctl daemon-reload
    sudo systemctl restart xrdp || sudo systemctl start xrdp || sudo systemctl status xrdp

    cd /etc
    sudo git add .
    sudo git commit -a -m "Installed xrdp from sources"

    sudo sed -i 's/.*crypt_level=.*/crypt_level=none/g' /etc/xrdp/xrdp.ini
    sudo sed -i 's/.*max_bpp=.*/max_bpp=24/g' /etc/xrdp/xrdp.ini
    sudo sed -i 's/.*xserverbpp=.*/xserverbpp=24/g' /etc/xrdp/xrdp.ini

    # GUI access via XRDP
    sudo firewall-cmd --add-port=3389/tcp --permanent
    sudo firewall-cmd --add-port=3350/tcp --permanent
    sudo firewall-cmd --reload
    sudo systemctl enable xrdp
    sudo chcon --type=bin_t /usr/sbin/xrdp
    sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
    sudo sed -i 's/^\s*ListenAddress=127.0.0.1\s*$/ListenAddress=0.0.0.0/g' /etc/xrdp/sesman.ini

    sudo systemctl daemon-reload
    sudo systemctl start xrdp || sudo systemctl status xrdp || echo "Error starting xrdp service..."
    sudo netstat -antup | grep xrdp || echo "Error checking if xrdp ports are listening for connections..."

    cd /etc
    sudo git add .
    sudo git commit -a -m "Configured xrdp"

}

function fix_locales() {

    echo ' ' | sudo tee -a /etc/profile.d/sh.local
    echo 'export LC_ALL="en_US.UTF-8"' | sudo tee -a /etc/profile.d/sh.local
    echo 'export LC_CTYPE="en_US.UTF-8"' | sudo tee -a /etc/profile.d/sh.local
    echo 'export LANGUAGE="en_US.UTF-8"' | sudo tee -a /etc/profile.d/sh.local
    echo 'export LANG="en_US.UTF-8"' | sudo tee -a /etc/profile.d/sh.local

    cd /etc
    sudo git add .
    sudo git commit -a -m "Configured centos locales."

}

general_configuration
permissions_fixes

if [ -z "${1}" ] || [ "" == "${1}"]; then
    # No need for this ones if creating a buildBot ...
    configuration_extras
    setup_xrdp
fi

fix_locales

echo " "
echo " "
echo "Please remember after running all this scripts you need to reboot the AMI image, so users and group changes are loaded."
echo "To do it, run (for example) shutdown -r now "
echo " "
echo " "
