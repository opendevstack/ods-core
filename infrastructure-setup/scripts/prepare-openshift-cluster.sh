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

oc login -u system:admin

oc new-project cd --description="Base project holding the templates and the Repositoy Manager" --display-name="OpenDevStack Templates"

oc adm policy --as system:admin add-cluster-role-to-user cluster-admin developer

oc create sa deployment -n cd
oc adm policy --as system:admin add-cluster-role-to-user cluster-admin system:serviceaccount:cd:deployment

echo -e "Save token to use in rundeck for deployment in ${BASE_DIR}/openshift-api-token\n"
oc sa get-token deployment -n cd > ${BASE_DIR}/sa-deployment-token.txt

cd ${BASE_DIR}/ods-project-quickstarters/ocp-templates/scripts/
./upload-templates.sh

#create secrets for cd_user
oc process -n cd templates/secrets -p PROJECT=cd | oc create -n cd -f-

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

echo -e "Create and replace old registry cert"
oc project default
REGISTRY_IP=`oc get service docker-registry -o jsonpath='{.spec.clusterIP}'`
REGISTRY_HOSTNAME=`oc get route/docker-registry -o jsonpath='{.spec.host}'`


echo "Expose registry route"
oc create route edge --service=docker-registry --hostname=docker-registry-default.192.168.56.101.nip.io -n default

