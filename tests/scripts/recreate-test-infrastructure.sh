#!/usr/bin/env bash
set -uxe


URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')

if [ ${URL} != "https://172.17.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
    exit 1
fi

if ! oc get clusterroles | grep request_role; then
  oc create -f ${BASH_SOURCE%/*}/json/create-cluster-role.json
fi

if [ ! -d ${BASH_SOURCE%/*}/../../ods-config ]; then
    mkdir -p ${BASH_SOURCE%/*}/../../ods-config
fi

${BASH_SOURCE%/*}/create-env-from-local-cluster.sh --base-oc-dir=${HOME}/openshift.local.clusterup --output ${BASH_SOURCE%/*}/../../ods-config/ods-core.env

if [ -d "${BASH_SOURCE%/*}/../../../ods-configuration" ]; then
    rm -rf "${BASH_SOURCE%/*}/../../../ods-configuration"
fi

NAMSPACE="cd"
REF="cicdtests"

if ! oc whoami; then
    echo "You must be logged in to the OC Cluster"
fi

if oc project ${NAMSPACE}; then
    oc delete project ${NAMSPACE}
fi

${BASH_SOURCE%/*}/deploy-mocks.sh  --verbose --wait
${BASH_SOURCE%/*}/setup-mocked-ods-repo.sh --ods-ref ${REF} --verbose

${BASH_SOURCE%/*}/../../ods-setup/setup-ods-project.sh --verbose --force --namespace ${NAMSPACE}

${BASH_SOURCE%/*}/../../ods-setup/setup-jenkins-images.sh --namespace ${NAMSPACE} --force --verbose --ods-ref ${REF}

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env
PROJECT_ID=prov
if oc project "${PROJECT_ID}-test" > /dev/null; then
    oc delete project "${PROJECT_ID}-test"
fi
if oc project "${PROJECT_ID}-dev" > /dev/null; then
    oc delete project "${PROJECT_ID}-dev"
fi
if oc project "${PROJECT_ID}-cd" > /dev/null; then
    oc delete project "${PROJECT_ID}-cd"
fi

PROJECT_ID=${PROJECT_ID} \
    ${BASH_SOURCE%/*}/../../create-projects/create-projects.sh  --verbose

PROJECT_ID=${PROJECT_ID} \
CD_USER_TYPE=general \
CD_USER_ID_B64=${CD_USER_ID_B64} \
PIPELINE_TRIGGER_SECRET=${PIPELINE_TRIGGER_SECRET_B64} \
    ${BASH_SOURCE%/*}/../../create-projects/create-cd-jenkins.sh --ods-namespace ${NAMSPACE} --force --verbose

oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:prov-cd:jenkins
