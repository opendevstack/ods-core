#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/


BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
NEXUS_ADMIN_USER="admin"
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

# Source the core configuration to get nexus informations
. $BASE_DIR/ods-configuration/ods-core.env

# Source local env informations to get nexus admin user
if [ ! -f "${BASE_DIR}/local.config" ] ; then
  echo "Local config file not found, will use default values"
else
  echo "Source local env default values"
  . $BASE_DIR/local.env.config
fi


oc login -u system:admin
oc project cd

cd /ods/ods-core/nexus/ocp-config
# yes 'y' | tailor update -v --force

cd ${cwd}

STATUS_CODE="000"

echo "Waiting for Nexus to get available"
while [ "$STATUS_CODE" != "200" ]
do
  sleep 5s
  echo -n "."
  STATUS_CODE=$(curl --insecure -s -o /dev/null -w %{http_code} https://nexus-cd.192.168.56.101.nip.io/)
done

echo "Create Nexus resources"
cd /ods/ods-core/infrastructure-setup/scripts/

# check if generated nexus password exists
$(oc rsh -n cd $(oc get pods -n cd | cut -d" " -f1 | grep "nexus") test -f "/nexus-data/admin.password")
if [ $? -eq 0 ]
then 
  NEXUS_PW=$(echo `oc -n cd rsh $(oc get pods -n cd | cut -d" " -f1 | grep "nexus") cat /nexus-data/admin.password`|tr -d '\r')  
else
  NEXUS_PW=admin123
fi


#create nexus resources
./create-nexus-resources.sh $NEXUS_HOST $NEXUS_ADMIN_USER $NEXUS_PW

cd ${BASE_DIR}





