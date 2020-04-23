#!/usr/bin/env bash
set -ue

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

ADMIN_USER_NAME=admin
ADMIN_USER_DEFAULT_PASSWORD=admin
ADMIN_USER_PASSWORD=
PIPELINE_USER_NAME=cd_user
PIPELINE_USER_PWD=
TOKEN_NAME=ods-jenkins-shared-library
SONARQUBE_URL=

function usage {
    printf "Setup SonarQube.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-s|--sonarqube\t\tSonarQube URL, e.g. 'https://bitbucket.sonarqube.com'\n"
    printf "\t-a|--admin-password\t\tAdmin password\n"
    printf "\t-p|--pipeline-user\tName of Jenkins pipeline user (defaults to 'cd_user')\n"
    printf "\t-t|--token-name\t\tName of SonarQube user token (defaults to 'ods-jenkins-shared-library')\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -a|--admin-password) ADMIN_USER_PASSWORD="$2"; shift;;
    -a=*|--admin-password=*) ADMIN_USER_PASSWORD="${1#*=}";;

    -p|--pipeline-user) PIPELINE_USER_NAME="$2"; shift;;
    -p=*|--pipeline-user=*) PIPELINE_USER_NAME="${1#*=}";;

    -t|--token-name) TOKEN_NAME="$2"; shift;;
    -t=*|--token-name=*) TOKEN_NAME="${1#*=}";;

    -s|--sonarqube) SONARQUBE_URL="$2"; shift;;
    -s=*|--sonarqube=*) SONARQUBE_URL="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! which jq >/dev/null; then
    echo_warn "Binary 'jq' (https://stedolan.github.io/jq/) is not in your PATH. This will make the script less comfortable to use."
    read -e -p "Continue anyway? [y/n] " input
    if [ "${input:-""}" != "y" ]; then
        exit 1
    fi
fi

if [ -z ${SONARQUBE_URL} ]; then
    read -e -p "Enter SonarQube URL (e.g. https://example.sonarqube.com): " input
    SONARQUBE_URL=${input:-""}
fi

if [ -z ${ADMIN_USER_PASSWORD} ]; then
    echo "Please enter SonarQube admin password:"
    read -e -s input
    ADMIN_USER_PASSWORD=${input:-""}
fi

echo_info "Checking if '${ADMIN_USER_NAME}' uses default password '${ADMIN_USER_DEFAULT_PASSWORD}'"
if curl -X POST --fail --silent \
    "${SONARQUBE_URL}/api/authentication/login?login=${ADMIN_USER_NAME}&password=${ADMIN_USER_DEFAULT_PASSWORD}"; then
    echo_info "Default password '${ADMIN_USER_DEFAULT_PASSWORD}' is used, updating it now."
    if ! curl -X POST --fail --silent --user ${ADMIN_USER_NAME}:${ADMIN_USER_NAME} \
        "${SONARQUBE_URL}/api/users/change_password?login=${ADMIN_USER_NAME}&password=${ADMIN_USER_PASSWORD}&previousPassword=${ADMIN_USER_DEFAULT_PASSWORD}"; then
        echo_error "Could not change default password of '${ADMIN_USER_NAME}'."
        exit 1
    fi
    base64Password=$(echo -n $ADMIN_USER_PASSWORD | base64)
    echo_info "Base64-encoded password to use for 'SONAR_ADMIN_PASSWORD_B64': ${base64Password}"
    echo_info "Default password changed"
else
    echo_info "Default password is not in use."
fi

echo_info "Setting sonar.forceAuthentication=true"
if ! curl -X POST --fail --silent --user ${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD} \
    "${SONARQUBE_URL}/api/settings/set?key=sonar.forceAuthentication&value=true"; then
    echo_error "Could not enable sonar.forceAuthentication."
    exit 1
fi
echo_info "sonar.forceAuthentication is enabled"

echo_info "Checking if '${PIPELINE_USER_NAME}' exists"
if curl -X POST --fail --silent --user ${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD} \
    "${SONARQUBE_URL}/api/users/search?q=${PIPELINE_USER_NAME}" | grep '"users":\[\]' >/dev/null; then
    echo_info "No user '${PIPELINE_USER_NAME}' present yet."
    if [ -z ${PIPELINE_USER_PWD} ]; then
        echo "Please enter '${PIPELINE_USER_NAME}' password:"
        read -e -s input
        PIPELINE_USER_PWD=${input:-""}
    fi
    echo_info "Trying to login in with '${PIPELINE_USER_NAME}'"
    if ! curl -X POST --fail --silent \
        "${SONARQUBE_URL}/api/authentication/login?login=${PIPELINE_USER_NAME}?password=${PIPELINE_USER_PWD}"; then
        echo_error "Could not login with '${PIPELINE_USER_NAME}'."
        exit 1
    fi
    echo_info "User token created"
fi
echo_info "User '${PIPELINE_USER_NAME}' exists in SonarQube"

echo_info "Checking if there are already tokens for '${PIPELINE_USER_NAME}'"
if ! curl --fail --silent --user ${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD} \
    "${SONARQUBE_URL}/api/user_tokens/search?login=${PIPELINE_USER_NAME}" | grep '"userTokens":\[\]' >/dev/null; then
    echo_info "There are already token(s) for '${PIPELINE_USER_NAME}'."
else
    echo_info "Creating token for '${PIPELINE_USER_NAME}'."
    tokenResponse=$(curl -X POST --fail --silent --user ${ADMIN_USER_NAME}:${ADMIN_USER_PASSWORD} \
        "${SONARQUBE_URL}/api/user_tokens/generate?login=${PIPELINE_USER_NAME}&name=${TOKEN_NAME}")
    # Example response:
    # {"login":"cd_user","name":"foo","token":"bar","createdAt":"2020-04-22T13:21:54+0000"}
    if which jq >/dev/null; then
        token=$(echo $tokenResponse | jq -r .token)
        echo_info "Created token: ${token}"
        base64Token=$(echo -n $token | base64)
        echo_info "Base64-encoded token to use for 'SONAR_AUTH_TOKEN_B64': ${base64Token}"
    else
        echo_info "Created token! Response: ${tokenResponse}"
    fi
fi

echo "If configuration needs to be updated, please add the base64 encoded token and the admin password into ods-core.env."

echo_done "SonarQube configured"
