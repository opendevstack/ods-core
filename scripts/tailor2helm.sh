#bin/bash

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

echo_done(){
    echo -e "\033[92mDONE\033[39m: $1"
}

echo_warn(){
    echo -e "\033[93mWARN\033[39m: $1"
}

echo_error(){
    echo -e "\033[31mERROR\033[39m: $1"
}

echo_info(){
    echo -e "\033[94mINFO\033[39m: $1"
}

LABEL=""
RELEASE=""
NAMESPACE=""

function usage {
    printf "Adopt Tailor resources into Helm release.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "Namespace is optional, but will be read from ods-core.env if available.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\n"
    printf "\t-l|--label\t\tResources label, e.g. 'app=component'\n"
    printf "\t-r|--release\t\tHelm relese\n"
    printf "\t-n|--namespace\t\tODS namespace\n"    
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -l|--label) LABEL="$2"; shift;;
    -l=*|--label=*) LABEL="${1#*=}";;

    -r|--release) RELEASE="$2"; shift;;
    -r=*|--release=*) RELEASE="${1#*=}";;

    -o|--namespace) NAMESPACE="$2"; shift;;
    -o=*|--namespace=*) NAMESPACE="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ] && [ -z "${NAMESPACE}" ]; then
    NAMESPACE=$(../scripts/get-config-param.sh ODS_NAMESPACE)
fi

if [ -z "${LABEL}" ]; then
    read -r -e -p "Enter label of the resources to adopt: " input
    LABEL="${input}"
fi

if [ -z "${RELEASE}" ]; then
    read -r -e -p "Enter helm release name: " input
    RELEASE="${input}"
fi

KINDS='ImageStream,BuildConfig,Service,DeploymentConfig,Deployment,Route,ConfigMap,Secret,PersistentVolumeClaim,ServiceAccount,RoleBinding'
RESOURCES=$(oc -n $NAMESPACE get $KINDS -l $LABEL -o template='{{range .items}}{{.kind}}/{{.metadata.name}} {{end}}')

for RESOURCE in $RESOURCES; do
    echo "Adopting $RESOURCE ..."
    oc -n $NAMESPACE annotate $RESOURCE meta.helm.sh/release-name=$RELEASE
    oc -n $NAMESPACE annotate $RESOURCE meta.helm.sh/release-namespace=$NAMESPACE
    oc -n $NAMESPACE label $RESOURCE app.kubernetes.io/managed-by=Helm
done