#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

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

ADMIN_USER=admin
ADMIN_DEFAULT_PASSWORD=
ADMIN_PASSWORD=
DEVELOPER_PASSWORD=
NEXUS_URL=
LOCAL_CONTAINER_ID=
NAMESPACE="ods"
NEXUS_DC="nexus3"
INSECURE=

function usage {
    printf "Setup Nexus.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-n|--nexus\t\tNexus URL, e.g. 'https://nexus.example.com'\n"
    printf "\t-l|--local-container-id\t\tLocal container ID\n"
    printf "\t-a|--admin-password\t\tAdmin password\n"
    printf "\t-d|--developer-password\t\tDeveloper password\n"
    printf "\t-n|--namespace\tNamespace (defaults to '${NAMESPACE}')\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -i|--insecure) INSECURE="--insecure";;

    -l|--local-container-id) LOCAL_CONTAINER_ID="$2"; shift;;
    -l=*|--local-container-id=*) LOCAL_CONTAINER_ID="${1#*=}";;

    -a|--admin-password) ADMIN_PASSWORD="$2"; shift;;
    -a=*|--admin-password=*) ADMIN_PASSWORD="${1#*=}";;

    -d|--developer-password) DEVELOPER_PASSWORD="$2"; shift;;
    -d=*|--developer-password=*) DEVELOPER_PASSWORD="${1#*=}";;

    -n|--nexus) NEXUS_URL="$2"; shift;;
    -n=*|--nexus=*) NEXUS_URL="${1#*=}";;

    --namespace=*) NAMESPACE="${1#*=}";;
    --namespace) NAMESPACE="$2"; shift;;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z ${LOCAL_CONTAINER_ID} ]; then
    if ! oc whoami > /dev/null; then
        echo "You need to log into OpenShift first"
        exit 1
    fi
fi

if [ -z ${NEXUS_URL} ]; then
    configuredUrl="https://nexus.example.com"
    if [ -f ${ODS_CORE_DIR}/../ods-configuration/ods-core.env ]; then
        echo_info "Configuration located"
        configuredUrl=$(cat ${ODS_CORE_DIR}/../ods-configuration/ods-core.env | grep NEXUS_URL | cut -d "=" -f 2- <<< "$s")
    fi
    read -e -p "Enter Nexus URL [${configuredUrl}]: " input
    if [ -z ${input} ]; then
        NEXUS_URL=${configuredUrl}
    else
        NEXUS_URL=${input:-""}
    fi
fi

if [ -z ${ADMIN_PASSWORD} ]; then
    echo "Please enter Nexus admin password:"
    read -e -s input
    ADMIN_PASSWORD=${input:-""}
fi

if [ -z ${DEVELOPER_PASSWORD} ]; then
    if [ -f ${ODS_CORE_DIR}/../ods-configuration/ods-core.env ]; then
        echo_info "Configuration located, checking if password is changed from sample value"
        samplePassword=$(cat ${ODS_CORE_DIR}/configuration-sample/ods-core.env.sample | grep NEXUS_PASSWORD_B64 | cut -d "=" -f 2- <<< "$s")
        configuredPassword=$(cat ${ODS_CORE_DIR}/../ods-configuration/ods-core.env | grep NEXUS_PASSWORD_B64 | cut -d "=" -f 2- <<< "$s" | base64 --decode)
        if [ "${configuredPassword}" == "${samplePassword}" ]; then
            echo_info "Admin password in ods-configuration/ods-core.env is the sample value"
        else
            echo_info "Setting admin password from ods-configuration/ods-core.env"
            DEVELOPER_PASSWORD=${configuredPassword}
        fi
    fi
    if [ -z ${DEVELOPER_PASSWORD} ]; then
        echo "Please enter Nexus admin password:"
        read -e -s input
        DEVELOPER_PASSWORD=${input:-""}
    fi
fi

function waitForReady {
    echo_info "Wait for Nexus to become responsive"
    set +e
    n=0
    until [ $n -ge 20 ]; do
        httpOk=$(curl ${INSECURE} --silent -o /dev/null -w "%{http_code}" "${NEXUS_URL}/service/rest/v1/status/writable")
        if [ "${httpOk}" == "200" ]; then
            echo_info "Nexus is up"
            break
        else
            echo_info "Nexus is not up yet, waiting 10s ..."
            sleep 10s
            n=$[$n+1]
        fi
    done
    set -e
}

function runJsonScript {
    local jsonScriptName=$1
    shift 1
    local runParams="$@"
    curl ${INSECURE} -X POST --fail --silent \
        --user ${ADMIN_USER}:${ADMIN_PASSWORD} \
        --header 'Content-Type: application/json' \
        "${NEXUS_URL}/service/rest/v1/script" -d @json/${jsonScriptName}.json
    curl ${INSECURE} -X POST --fail --silent \
        --user ${ADMIN_USER}:${ADMIN_PASSWORD} \
        --header 'Content-Type: text/plain' \
        "${NEXUS_URL}/service/rest/v1/script/${jsonScriptName}/run" ${runParams} > /dev/null
    curl ${INSECURE} -X DELETE --fail --silent \
        --user ${ADMIN_USER}:${ADMIN_PASSWORD} \
        "${NEXUS_URL}/service/rest/v1/script/${jsonScriptName}"
}

function changeScriptSetting {
    local allowCreation=$1
    echo_info "Changing nexus.scripts.allowCreation to '${allowCreation}'"
    local cmd="echo 'nexus.scripts.allowCreation=${allowCreation}' >> /nexus-data/etc/nexus.properties"
    if [ -z ${LOCAL_CONTAINER_ID} ]; then
        oc -n ${NAMESPACE} rsh dc/${NEXUS_DC} sh -c "${cmd}"
        echo_info "Rollout new Nexus deployment to apply changes"
        oc -n ${NAMESPACE} rollout latest dc/${NEXUS_DC}
        oc -n ${NAMESPACE} rollout status dc/${NEXUS_DC} --watch=true
    else
        if ! docker exec -t ${LOCAL_CONTAINER_ID} sh -c "${cmd}"; then
            echo_error "Cannot exec in local container"
            docker logs ${LOCAL_CONTAINER_ID}
            exit 1
        fi
        echo_info "Restart local container to apply changes"
        docker stop ${LOCAL_CONTAINER_ID} &> /dev/null
        docker start ${LOCAL_CONTAINER_ID} &> /dev/null
    fi
}

waitForReady

changeScriptSetting "true"

waitForReady

# If default password exists and can be used, update it with ADMIN_PASSWORD.
DEFAULT_ADMIN_PASSWORD_FILE="/nexus-data/admin.password"
if [ -z ${LOCAL_CONTAINER_ID} ]; then
    ADMIN_DEFAULT_PASSWORD=$(oc -n ${NAMESPACE} rsh dc/${NEXUS_DC} sh -c "cat ${DEFAULT_ADMIN_PASSWORD_FILE} 2> /dev/null || true")
else
    ADMIN_DEFAULT_PASSWORD=$(docker exec -t ${LOCAL_CONTAINER_ID} sh -c "cat ${DEFAULT_ADMIN_PASSWORD_FILE} 2> /dev/null || true")
fi
if [ ! -z ${ADMIN_DEFAULT_PASSWORD} ]; then
    pong=$(curl ${INSECURE} --silent --user ${ADMIN_USER}:${ADMIN_DEFAULT_PASSWORD} \
        "${NEXUS_URL}/service/metrics/ping")
    if [ "${pong}" == "pong" ]; then
        echo_info "Change admin password"
        curl ${INSECURE} -X POST --fail --silent \
            --user ${ADMIN_USER}:${ADMIN_DEFAULT_PASSWORD} \
            --header 'Content-Type: application/json' \
            "${NEXUS_URL}/service/rest/v1/script" -d @json/changeAdminPassword.json
        curl ${INSECURE} -X POST --fail --silent \
            --user ${ADMIN_USER}:${ADMIN_DEFAULT_PASSWORD} \
            --header 'Content-Type: text/plain' \
            "${NEXUS_URL}/service/rest/v1/script/changeAdminPassword/run" -d "${ADMIN_PASSWORD}" > /dev/null
        curl ${INSECURE} -X DELETE --fail --silent \
            --user ${ADMIN_USER}:${ADMIN_PASSWORD} \
            "${NEXUS_URL}/service/rest/v1/script/changeAdminPassword"
    fi
    echo_info "Delete default admin password file"
    if [ -z ${LOCAL_CONTAINER_ID} ]; then
        oc -n ${NAMESPACE} rsh dc/${NEXUS_DC} rm ${DEFAULT_ADMIN_PASSWORD_FILE}
    else
        docker exec -t ${LOCAL_CONTAINER_ID} rm ${DEFAULT_ADMIN_PASSWORD_FILE}
    fi
else
    echo_info "File '${DEFAULT_ADMIN_PASSWORD_FILE}' does not exist - continuing with actual password"
fi

echo_info "Install Blob Stores"
runJsonScript "createBlobStores"

echo_info "Install Repositories"
runJsonScript "createRepos"

echo_info "Deactivate anonymous access"
runJsonScript "deactivateAnonymous"

echo_info "Setup developer role"
runJsonScript "createRole" "-d @json/developer-role.json"

echo_info "Setup developer user"
sed "s|@developer_password@|${DEVELOPER_PASSWORD}|g" json/developer-user.json > json/developer-user-with-password.json
runJsonScript "createUser" "-d @json/developer-user-with-password.json"
rm json/developer-user-with-password.json

changeScriptSetting "false"

waitForReady
