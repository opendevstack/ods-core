#!/bin/sh

# This script downloads and installs Keycloak.
# Use the VERSION environment variable below to define the version to be used.

VERSION=4.8.3.Final

DOWNLOAD_URL=http://downloads.jboss.org/keycloak/${VERSION}/keycloak-${VERSION}.tar.gz


echo "Installing Java 8 JDK ..."
yum -y -q install java-1.8.0-openjdk-devel

echo "Installing epel-release repository ..."
yum -y install epel-release

echo "Installing jq..."
yum -y install jq

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
ln -s /opt/keycloak-${VERSION} /opt/keycloak

cp -f /vagrant/conf/wildfly.conf /etc/default/wildfly.conf

cp -f /vagrant/conf/wildfly-init-redhat.sh /opt/keycloak/wildfly-init-redhat.sh

chmod a+x /opt/keycloak/wildfly-init-redhat.sh
chown vagrant:vagrant /opt/keycloak/wildfly-init-redhat.sh

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

cd /opt/keycloak/bin
echo "Login to keycloak via admin user"
./kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user admin --password admin

REALM=opendevstack

echo "create realm $REALM..."

./kcadm.sh create realms -s realm=$REALM -s enabled=true

echo "create roles 'opendevstack-administrators' and 'opendevstack-user'"
./kcadm.sh create roles -r $REALM -s name=opendevstack-administrators -s 'description=OpenDevStack administrators are allowed to create project initiatives and add quickstarters to to existing initiatives.'
./kcadm.sh create roles -r $REALM -s name=opendevstack-users -s 'description=OpenDevStack Users are allowed to add quickstarters to existing project initiatives.'

echo "create user 'user1'"
./kcadm.sh create users -r  $REALM -s username=user1 -s enabled=true
./kcadm.sh set-password -r $REALM --username user1 --new-password user1
./kcadm.sh add-roles --uusername user1 --rolename opendevstack-users -r $REALM

echo "create user 'admin1'"
./kcadm.sh create users -r  $REALM -s username=admin1 -s enabled=true
./kcadm.sh set-password -r $REALM --username admin1 --new-password admin1
./kcadm.sh add-roles --uusername admin1 --rolename opendevstack-users --rolename opendevstack-administrators -r $REALM

CLIENT_NAME=ods-provisioning-app

echo "create client '$CLIENT_NAME'"
./kcadm.sh create clients -r $REALM -s clientId=$CLIENT_NAME -s 'redirectUris=["*"]'

echo "create 'User Realm Role' mapper in client $CLIENT_NAME"
CLIENT_ID=$(./kcadm.sh get clients -r $REALM -q clientId=ods-provisioning-app --fields id | jq -r '.[0].id')

./kcadm.sh create -r $REALM clients/$CLIENT_ID/protocol-mappers/models -f - << 'EOF'
{
  "name": "Group Mapper",
  "protocol": "openid-connect",
  "protocolMapper": "oidc-group-membership-mapper",
  "consentRequired": false,
  "config": {
    "full.path": "false",
    "id.token.claim": "true",
    "access.token.claim": "true",
    "claim.name": "roles",
    "userinfo.token.claim": "true"
  }
}
EOF

echo "Opening port 8080 on iptables ..."
iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
iptables-save > /etc/sysconfig/iptables