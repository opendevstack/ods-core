#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/


BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

oc login -u system:admin
oc project cd

cd /ods/ods-core/nexus/ocp-config
yes 'y' | tailor update -v --force

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
./create-nexus-resources.sh

cd ${BASE_DIR}





