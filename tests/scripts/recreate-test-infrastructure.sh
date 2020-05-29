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

if [ ! -d ${BASH_SOURCE%/*}/../../../ods-configuration ]; then
    mkdir -p ${BASH_SOURCE%/*}/../../../ods-configuration
else
    rm -rf ${BASH_SOURCE%/*}/../../../ods-configuration
    mkdir -p ${BASH_SOURCE%/*}/../../../ods-configuration
fi

${BASH_SOURCE%/*}/create-env-from-local-cluster.sh --base-oc-dir=${HOME}/openshift.local.clusterup --output ${BASH_SOURCE%/*}/../../../ods-configuration/ods-core.env

NAMESPACE="ods"
REF="cicdtests"

if ! oc whoami; then
    echo "You must be logged in to the OC Cluster"
fi

if oc project ${NAMESPACE}; then
    oc delete project ${NAMESPACE}
fi

${BASH_SOURCE%/*}/deploy-mocks.sh  --verbose --wait
${BASH_SOURCE%/*}/setup-mocked-ods-repo.sh --ods-ref ${REF} --verbose

${BASH_SOURCE%/*}/../../ods-setup/setup-ods-project.sh --verbose --non-interactive

cd ${BASH_SOURCE%/*}/../../jenkins/ocp-config/build && tailor apply --namespace ${NAMESPACE} --non-interactive && cd -
${BASH_SOURCE%/*}/../../ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-master
${BASH_SOURCE%/*}/../../ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-slave-base
${BASH_SOURCE%/*}/../../ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-webhook-proxy



source ${BASH_SOURCE%/*}/../../../ods-configuration/ods-core.env
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
    ${BASH_SOURCE%/*}/../../create-projects/create-projects.sh  --verbose -p ${PROJECT_ID}

PROJECT_ID=${PROJECT_ID}
CD_USER_TYPE=general
CD_USER_ID_B64=${CD_USER_ID_B64}
PIPELINE_TRIGGER_SECRET=${PIPELINE_TRIGGER_SECRET_B64}

${BASH_SOURCE%/*}/../../create-projects/create-cd-jenkins.sh --ods-namespace ${NAMESPACE} --verbose --cd-user-type ${CD_USER_TYPE} --cd-user-id-b64 ${CD_USER_ID_B64} --pipeline-trigger-secret-b64 ${PIPELINE_TRIGGER_SECRET_B64} --project ${PROJECT_ID}


oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:prov-cd:jenkins
