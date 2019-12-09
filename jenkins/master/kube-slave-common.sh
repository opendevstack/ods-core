#!/bin/sh
#
# This file provides functions to automatically discover suitable image streams
# that the Kubernetes plugin will use to create "slave" pods.
# The image streams has to have label "role" set to "jenkins-slave".
#
# The Jenkins container also need permissions to access the OpenShift API to
# list image streams. You have to run this command to allow that:
#
# $ oc policy add-role-to-user edit system:serviceaccount:ci:default -n ci
#
# (where the 'ci' is the namespace where Jenkins runs)

export DEFAULT_SLAVE_DIRECTORY=/tmp
export SLAVE_LABEL="jenkins-slave"
JNLP_SERVICE_NAME=${JNLP_SERVICE_NAME:-JENKINS_JNLP}
JNLP_SERVICE_NAME=`echo ${JNLP_SERVICE_NAME} | tr '[a-z]' '[A-Z]' | tr '-' '_'`
T_HOST=${JNLP_SERVICE_NAME}_SERVICE_HOST
# the '!' handles env variable indirection so we can resolve the nested variable
# see: http://stackoverflow.com/a/14204692
JNLP_HOST=${!T_HOST}
T_PORT=${JNLP_SERVICE_NAME}_SERVICE_PORT
JNLP_PORT=${!T_PORT}

export JNLP_PORT=${JNLP_PORT:-50000}

# The project name equals to the namespace name where the container with jenkins
# runs. You can override it by setting the PROJECT_NAME variable.
# If there is no environment variable and this container does not run in
# kubernetes, the default value "ci" is used.
if [ -z "${PROJECT_NAME}" ]; then
  if [ -f "${KUBE_SA_DIR}/namespace" ]; then
    export PROJECT_NAME=$(cat "${KUBE_SA_DIR}/namespace")
  else
    export PROJECT_NAME="ci"
  fi
else
  export PROJECT_NAME
fi

export JENKINS_PASSWORD KUBERNETES_SERVICE_HOST KUBERNETES_SERVICE_PORT
export K8S_PLUGIN_POD_TEMPLATES=""
export PATH=$PATH:${JENKINS_HOME}/.local/bin

function has_service_account() {
  [ -f "${AUTH_TOKEN}" ]
}

if has_service_account; then
  export oc_auth="--token=$(cat $AUTH_TOKEN) --certificate-authority=${KUBE_CA}"
  export oc_cmd="oc --server=$OPENSHIFT_API_URL ${oc_auth}"
  export oc_serviceaccount_name="$(expr "$(oc whoami)" : 'system:serviceaccount:[a-z0-9][-a-z0-9]*:\([a-z0-9][-a-z0-9]*\)' || true)"
fi

# generate_kubernetes_config generates a configuration for the kubernetes plugin
function generate_kubernetes_config() {
    [ -z "$oc_cmd" ] && return
    [ ! has_service_account ] && return
    local crt_contents=$(cat "${KUBE_CA}")
    echo "
    <org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
      <name>openshift</name>
      <templates>
      </templates>
      <serverUrl>https://kubernetes.default:${KUBERNETES_SERVICE_PORT}</serverUrl>
      <skipTlsVerify>false</skipTlsVerify>
      <serverCertificate>${crt_contents}</serverCertificate>
      <namespace>${PROJECT_NAME}</namespace>
      <jenkinsUrl>http://jenkins.${PROJECT_NAME}.svc:${JENKINS_SERVICE_PORT}</jenkinsUrl>
      <jenkinsTunnel>jenkins-jnlp.${PROJECT_NAME}.svc:${JNLP_PORT}</jenkinsTunnel>
      <credentialsId>1a12dfa4-7fc5-47a7-aa17-cc56572a41c7</credentialsId>
      <containerCap>10</containerCap>
      <retentionTimeout>5</retentionTimeout>
    </org.csanchez.jenkins.plugins.kubernetes.KubernetesCloud>
    "
}

# generate_kubernetes_credentials generates the credentials entry for the
# kubernetes service account.
function generate_kubernetes_credentials() {
  echo "<entry>
      <com.cloudbees.plugins.credentials.domains.Domain>
        <specifications/>
      </com.cloudbees.plugins.credentials.domains.Domain>
      <java.util.concurrent.CopyOnWriteArrayList>
        <org.csanchez.jenkins.plugins.kubernetes.ServiceAccountCredential plugin=\"kubernetes@0.4.1\">
          <scope>GLOBAL</scope>
          <id>1a12dfa4-7fc5-47a7-aa17-cc56572a41c7</id>
          <description></description>
        </org.csanchez.jenkins.plugins.kubernetes.ServiceAccountCredential>
      </java.util.concurrent.CopyOnWriteArrayList>
    </entry>
    "
}
