#!/usr/bin/env bash
# This script is meant to be usd on the openshift VM
export PATH=$PATH:/usr/local/bin/

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
CLUSTER_DIR=/opt/oc/profiles/odsdev
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

# set sufficient max map count for elastic search pods (also used by sonar)
LINE='vm.max_map_count=262144'
FILE='/etc/sysctl.conf'
grep -qF -- "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
sysctl -p


cd_user_config_location=${BASE_DIR}/ods-configuration/ods-core.env
if [[ ! -f $cd_user_config_location ]]; then
	echo "Cannot find file: ${cd_user_config_location} - please ensure you have created the ods-configuration repo (through ods-core/configuration-sample/update)"
	exit 1
fi

oc login -u system:admin

oc new-project cd --description="Base project holding the templates and the Repositoy Manager" --display-name="OpenDevStack Templates"

oc adm policy --as system:admin add-cluster-role-to-user cluster-admin developer

# Allow system:authenticated group to pull images from CD namespace
oc adm policy add-cluster-role-to-group system:image-puller system:authenticated -n cd
oc adm policy add-role-to-group view system:authenticated -n cd

oc create sa deployment -n cd
oc adm policy --as system:admin add-cluster-role-to-user cluster-admin system:serviceaccount:cd:deployment

# create secrets for global cd_user
CD_USER_PWD_B64=$(grep CD_USER_PWD_B64 $cd_user_config_location | cut -d '=' -f 2-)
oc process -f ${BASE_DIR}/ods-core/infrastructure-setup/ocp-config/cd-user/secret.yml -p CD_USER_PWD_B64=${CD_USER_PWD_B64} |  oc create -n cd -f-

if [[ ! -d "${BASE_DIR}/certs" ]] ; then
  echo "creating certs directory"
  mkdir ${BASE_DIR}/certs
fi

cd ${BASE_DIR}/certs

echo -e "Create and replace old router cert"
oc project default
oc get --export secret -o yaml router-certs > ${BASE_DIR}/old-router-certs-secret.yaml
oc adm ca create-server-cert --signer-cert=${CLUSTER_DIR}/kube-apiserver/ca.crt --signer-key=${CLUSTER_DIR}/kube-apiserver/ca.key --signer-serial=${CLUSTER_DIR}/kube-apiserver/ca.serial.txt --hostnames='kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,localhost,openshift,openshift.default,openshift.default.svc,openshift.default.svc.cluster,openshift.default.svc.cluster.local,127.0.0.1,172.17.0.1,172.30.0.1,*.192.168.56.101.nip.io,192.168.56.101,*.router.default.svc.cluster.local,router.default.svc.cluster.local' --cert=router.crt --key=router.key
cat router.crt ${CLUSTER_DIR}/kube-apiserver/ca.crt router.key > router.pem
oc create secret tls router-certs --cert=router.pem --key=router.key -o json --dry-run | oc replace -f -
oc annotate service router service.alpha.openshift.io/serving-cert-secret-name- service.alpha.openshift.io/serving-cert-signed-by-
oc annotate service router service.alpha.openshift.io/serving-cert-secret-name=router-certs
oc rollout latest dc/router

echo "Expose registry route"
oc create route edge --service=docker-registry --hostname=docker-registry-default.192.168.56.101.nip.io -n default

