#!/usr/bin/env bash
set -ue

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

# From https://stackoverflow.com/questions/296536/how-to-urlencode-data-for-curl-command.
# The API of SonarQube is super weird and uses query parameters in a POST request,
# so we need a way to URI encode those. As this script depends on "jq" anyway,
# we use that as the easiest way to URI encode.
function uriencode { jq -nr --arg v "$1" '$v|@uri'; }

ADMIN_USER_NAME="admin"
ADMIN_USER_DEFAULT_PASSWORD="admin"
ADMIN_USER_PASSWORD=""
PIPELINE_USER_NAME="cd_user"
PIPELINE_USER_PWD=""
TOKEN_NAME="ods-jenkins-shared-library"
WRITE_TO_CONFIG=""
SONARQUBE_URL=""
INSECURE=""
CONFIGURATION_LOCATED=""
VALUES_WRITTEN_TO_CONFIG=""

function usage {
    printf "Setup SonarQube.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\n"
    printf "\t-s|--sonarqube\t\tSonarQube URL, e.g. 'https://sonarqube.example.com'\n"
    printf "\t-a|--admin-password\tAdmin password\n"
    printf "\t-p|--pipeline-user\tName of Jenkins pipeline user (defaults to 'cd_user')\n"
    printf "\t-t|--token-name\t\tName of SonarQube user token (defaults to 'ods-jenkins-shared-library')\n"
    printf "\t-w|--write-to-config\tIf token/password should be written to ods-core.env\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -i|--insecure) INSECURE="--insecure";;

    -a|--admin-password) ADMIN_USER_PASSWORD="$2"; shift;;
    -a=*|--admin-password=*) ADMIN_USER_PASSWORD="${1#*=}";;

    -p|--pipeline-user) PIPELINE_USER_NAME="$2"; shift;;
    -p=*|--pipeline-user=*) PIPELINE_USER_NAME="${1#*=}";;

    -w|--pipeline-user-password) PIPELINE_USER_PWD="$2"; shift;;
    -w=*|--pipeline-user-password=*) PIPELINE_USER_PWD="${1#*=}";;

    -t|--token-name) TOKEN_NAME="$2"; shift;;
    -t=*|--token-name=*) TOKEN_NAME="${1#*=}";;

    -c|--write-to-config) WRITE_TO_CONFIG="y";;

    -s|--sonarqube) SONARQUBE_URL="$2"; shift;;
    -s=*|--sonarqube=*) SONARQUBE_URL="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! which jq >/dev/null; then
    echo_error "'jq' (https://stedolan.github.io/jq/) is not in your \$PATH."
    exit 1
fi

if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    echo_info "Configuration located at ${ODS_CONFIGURATION_DIR}/ods-core.env."
    CONFIGURATION_LOCATED="y"
else
    echo_warn "Configuration could not be located."
    WRITE_TO_CONFIG="n"
fi

if [ -z "${SONARQUBE_URL}" ]; then
    configuredUrl="https://sonarqube.example.com"
    if [ -n "${CONFIGURATION_LOCATED}" ]; then
        configuredUrl=$(grep SONARQUBE_URL "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2-)
    fi
    read -r -e -p "Enter SonarQube URL [${configuredUrl}]: " input
    if [ -z "${input}" ]; then
        SONARQUBE_URL=${configuredUrl}
    else
        SONARQUBE_URL=${input:-""}
    fi
fi

if [ -z "${ADMIN_USER_PASSWORD}" ]; then
    if [ -n "${CONFIGURATION_LOCATED}" ]; then
        echo_info "Checking if password in ods-configuration/ods-core.env differs from sample value ..."
        samplePassword=$(grep SONAR_ADMIN_PASSWORD_B64 "${ODS_CORE_DIR}/configuration-sample/ods-core.env.sample" | cut -d "=" -f 2-)
        configuredPassword=$(grep SONAR_ADMIN_PASSWORD_B64 "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2- | base64 --decode)
        if [ "${configuredPassword}" == "${samplePassword}" ]; then
            echo_info "Admin password in ods-configuration/ods-core.env is the sample value."
        else
            echo_info "Using admin password from ods-configuration/ods-core.env."
            ADMIN_USER_PASSWORD=${configuredPassword}
        fi
    fi
    if [ -z "${ADMIN_USER_PASSWORD}" ]; then
        echo "Please enter SonarQube admin password:"
        read -r -e -s input
        ADMIN_USER_PASSWORD=${input:-""}
    fi
fi

echo_info "Wait for SonarQube to become responsive ..."
echo_info "Query: curl ${INSECURE} -sS -o /dev/null -w \"%{http_code}\" \"${SONARQUBE_URL}/api/server/version\""
# set +e
n=0
httpOk=
until [ $n -ge 20 ]; do
    httpOk=$(curl ${INSECURE} -sS -o /dev/null -w "%{http_code}" "${SONARQUBE_URL}/api/server/version")
    if [ "${httpOk}" == "200" ]; then
        echo_info "SonarQube is up (curl returned ${httpOk})."
        break
    else
        echo_info "SonarQube is not up yet (curl returned ${httpOk}), waiting 10s ..."
        sleep 10s
        n=$((n+1))
    fi
done
# set -e

if [ "${httpOk}" != "200" ]; then
    echo_error "SonarQube did not start, got HTTP code ${httpOk}."
    exit 1
fi

echo_info "Checking if '${ADMIN_USER_NAME}' uses default password '${ADMIN_USER_DEFAULT_PASSWORD}'."
encodedAdminUser="$(uriencode "${ADMIN_USER_NAME}")"
encodedAdminPassword="$(uriencode "${ADMIN_USER_PASSWORD}")"
encodedDefaultPassword="$(uriencode "${ADMIN_USER_DEFAULT_PASSWORD}")"
if curl ${INSECURE} -X POST -sf \
    "${SONARQUBE_URL}/api/authentication/login?login=${encodedAdminUser}&password=${encodedDefaultPassword}"; then
    echo_info "Default password '${ADMIN_USER_DEFAULT_PASSWORD}' is used, changing password for '${ADMIN_USER_NAME}' now."
    if ! curl ${INSECURE} -X POST -sSf --user "${ADMIN_USER_NAME}:${ADMIN_USER_NAME}" \
        "${SONARQUBE_URL}/api/users/change_password?login=${encodedAdminUser}&password=${encodedAdminPassword}&previousPassword=${encodedDefaultPassword}"; then
        echo_error "Could not change default password of '${ADMIN_USER_NAME}'."
        exit 1
    fi
    echo_info "Default password for '${ADMIN_USER_NAME}' changed."

    echo_info "Verifying login with new password ..."
    if ! curl ${INSECURE} -X POST -sSf \
        "${SONARQUBE_URL}/api/authentication/login?login=${encodedAdminUser}&password=${encodedAdminPassword}"; then
        echo_error "Could not login as '${ADMIN_USER_NAME}' using the new password."
        exit 1
    fi
    echo_info "Login for '${ADMIN_USER_NAME}' with new password successful."

    base64Password=$(echo -n "${ADMIN_USER_PASSWORD}" | base64)

    if [ -z "${WRITE_TO_CONFIG}" ]; then
        writeToConfigDefault="y"
        read -r -e -p "Write '${ADMIN_USER_NAME}' password to ods-core.env? [${writeToConfigDefault}]: " input
        if [ -z "${input}" ]; then
            WRITE_TO_CONFIG=${writeToConfigDefault}
        else
            WRITE_TO_CONFIG=${input:-""}
        fi
    fi
    if [ "${WRITE_TO_CONFIG}" == "y" ]; then
        echo_info "Writing SONAR_ADMIN_PASSWORD_B64=${base64Password} into ods-core.env ..."
        sed -ie "s|SONAR_ADMIN_PASSWORD_B64=.*$|SONAR_ADMIN_PASSWORD_B64=${base64Password}|g" "${ODS_CONFIGURATION_DIR}/ods-core.env"
        VALUES_WRITTEN_TO_CONFIG="y"
        echo_info "Value of 'SONAR_ADMIN_PASSWORD_B64' changed."
    else
        echo_warn "'${ADMIN_USER_NAME}' password changed, but not written to the config."
        echo_warn "Base64-encoded password to use for 'SONAR_ADMIN_PASSWORD_B64': ${base64Password}"
    fi
else
    echo_info "Default '${ADMIN_USER_NAME}' password is not in use."
fi

# Check whether pipeline user exists; create it if missing.
echo_info "Checking if '${PIPELINE_USER_NAME}' exists ..."
encodedPipelineUser="$(uriencode "${PIPELINE_USER_NAME}")"

# Query SonarQube for matching users and get count (fallback to 0 on error).
userCount=$(curl ${INSECURE} -sS --user "${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD}" \
    "${SONARQUBE_URL}/api/users/search?q=${encodedPipelineUser}" | jq -r '.users | length' || echo 0)

if [ "${userCount}" -eq 0 ]; then
    echo_info "No user '${PIPELINE_USER_NAME}' found — creating it now."

    if [ -z "${PIPELINE_USER_PWD}" ]; then
        echo "Enter password for '${PIPELINE_USER_NAME}':"
        read -r -e -s input
        PIPELINE_USER_PWD=${input:-""}
    fi

    encodedPipelinePassword="$(uriencode "${PIPELINE_USER_PWD}")"

    echo_info "Creating SonarQube user '${PIPELINE_USER_NAME}' ..."
    if ! curl ${INSECURE} -X POST -sSf --user "${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD}" \
        "${SONARQUBE_URL}/api/users/create?login=${encodedPipelineUser}&name=${encodedPipelineUser}&password=${encodedPipelinePassword}"; then
        echo_error "Could not create user '${PIPELINE_USER_NAME}'."
        exit 1
    fi
    echo_info "User '${PIPELINE_USER_NAME}' created."

    echo_info "Verifying login for '${PIPELINE_USER_NAME}' ..."
    if ! curl ${INSECURE} -X POST -sSf \
        "${SONARQUBE_URL}/api/authentication/login?login=${encodedPipelineUser}&password=${encodedPipelinePassword}"; then
        echo_error "Login verification for '${PIPELINE_USER_NAME}' failed."
        exit 1
    fi
    echo_info "Login for '${PIPELINE_USER_NAME}' successful."
else
    echo_info "User '${PIPELINE_USER_NAME}' already exists in SonarQube."
fi

sampleToken=$(grep SONAR_AUTH_TOKEN_B64 "${ODS_CORE_DIR}/configuration-sample/ods-core.env.sample" | cut -d "=" -f 2-)
configuredToken=$(grep SONAR_AUTH_TOKEN_B64 "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2- | base64 --decode)
authTokenVerified=""
if [ "${configuredToken}" == "${sampleToken}" ]; then
    echo_info "Auth token in ods-core.env is the sample value."
else
    echo_info "Checking if login with token from ods-core.env is possible ..."
    if curl ${INSECURE} -sSf --user "${configuredToken}": "${SONARQUBE_URL}/api/user_tokens/search?login=cd_user" > /dev/null; then
        echo_info "Configured token for '${PIPELINE_USER_NAME}' verified."
        authTokenVerified="y"
    fi
fi

if [ -z "${authTokenVerified}" ]; then
    echo_info "Creating token for '${PIPELINE_USER_NAME}' ..."
    encodedTokenName="$(uriencode "${TOKEN_NAME}")"
    tokenResponse=$(curl ${INSECURE} -X POST -sSf --user "${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD}" \
        "${SONARQUBE_URL}/api/user_tokens/generate?login=${encodedPipelineUser}&name=${encodedTokenName}")
    echo_info "Created token for '${PIPELINE_USER_NAME}'."
    # Example response:
    # {"login":"cd_user","name":"foo","token":"bar","createdAt":"2020-04-22T13:21:54+0000"}
    token=$(echo "${tokenResponse}" | jq -r .token)
    base64Token=$(echo -n "${token}" | base64)

    if [ -z "${WRITE_TO_CONFIG}" ]; then
        writeToConfigDefault="y"
        read -r -e -p "Write token to ods-core.env? [${writeToConfigDefault}]: " input
        if [ -z "${input}" ]; then
            WRITE_TO_CONFIG=${writeToConfigDefault}
        else
            WRITE_TO_CONFIG=${input:-""}
        fi
    fi
    if [ "${WRITE_TO_CONFIG}" == "y" ]; then
        echo_info "Writing SONAR_AUTH_TOKEN_B64=${base64Token} into ods-core.env ..."
        sed -ie "s|SONAR_AUTH_TOKEN_B64=.*$|SONAR_AUTH_TOKEN_B64=${base64Token}|g" "${ODS_CONFIGURATION_DIR}/ods-core.env"
        echo_info "Value of 'SONAR_AUTH_TOKEN_B64' changed."
        VALUES_WRITTEN_TO_CONFIG="y"
    else
        echo_warn "Auth token created, but not written to the config."
        echo_warn "Base64-encoded token to use for 'SONAR_AUTH_TOKEN_B64': ${base64Token}"
    fi
fi

if [ -n "${VALUES_WRITTEN_TO_CONFIG}" ]; then
    echo_warn "Some values in '${ODS_CONFIGURATION_DIR}/ods-core.env' have been updated."
    echo_warn "Commit and push the changes to Bitbucket."
fi

echo_done "SonarQube configured."
