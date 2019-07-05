#!/bin/sh

# This script downloads and installs Keycloak.
# Use the VERSION environment variable below to define the version to be used.

VERSION=4.8.3.Final

DOWNLOAD_URL=http://downloads.jboss.org/keycloak/${VERSION}/keycloak-${VERSION}.tar.gz

# Install Java
echo "Installing Java 8 JDK ..."
yum -y -q install java-1.8.0-openjdk-devel

# Install Keycloak
if [ -f "/vagrant/downloads/keycloak-${VERSION}.tar.gz" ];
then
    echo "Installing Keycloak from /vagrant/downloads/keycloak-${VERSION} ..."
else
    echo "Downloading Keycloak ${VERSION} ..."
    mkdir -p /vagrant/downloads
    wget -q -O /vagrant/downloads/keycloak-${VERSION}.tar.gz "${DOWNLOAD_URL}"
    if [ $? != 0 ];
    then
        echo "FATAL: Failed to download Keycloak from ${DOWNLOAD_URL}"
        exit 1
    fi

    echo "Installing Keycloak ..."
fi

tar xfz /vagrant/downloads/keycloak-${VERSION}.tar.gz -C /opt
rm -f /opt/keycloak
ln -s /opt/keycloak-${VERSION} /opt/keycloak

rm -f /etc/default/wildfly.conf
cp -f /vagrant/conf/wildfly.conf /etc/default/wildfly.conf

rm -f /etc/init.d/keycloak
cp -f /vagrant/conf/wildfly-init-redhat.sh /opt/keycloak/wildfly-init-redhat.sh
rm -f /etc/init.d/keycloak
ln -s /opt/keycloak/wildfly-init-redhat.sh /etc/init.d/keycloak
/sbin/chkconfig --add keycloak
/sbin/chkconfig --level 345 keycloak on

source /etc/default/wildfly.conf
mkdir -p /var/log/wildfly
chown -R ${JBOSS_USER} /var/log/wildfly /opt/keycloak-${VERSION}

# Start Keycloak
echo "Starting Keycloak ..."

/sbin/service keycloak start

/opt/keycloak/bin/add-user-keycloak.sh -u admin -p admin

/sbin/service keycloak restart

echo "Opening port 8080 on iptables ..."
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
iptables-save > /etc/sysconfig/iptables
