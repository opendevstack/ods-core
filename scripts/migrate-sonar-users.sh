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


SONARQUBE_URL=""
SONAR_ADMIN_USERNAME=""
SONAR_ADMIN_PASSWORD=""
INSECURE=""

function usage {
    printf "Migrate SonarQube users from Atlassian Crowd provider to Saml provider.\n\n"
    printf "This script will ask interactively for parameters if not in ods-configuraion.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\n"
    printf "\t-s|--sonarqube\t\tSonarQube URL, e.g. 'https://sonarqube.example.com'\n"
    printf "\t-u|--admin-user\tAdmin user\n"
    printf "\t-p|--admin-password\tAdmin password\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -i|--insecure) INSECURE="--insecure";;

    -p|--admin-password) SONAR_ADMIN_PASSWORD="$2"; shift;;
    -p=*|--admin-password=*) SONAR_ADMIN_PASSWORD="${1#*=}";;

    -u|--admin-user) SONAR_ADMIN_USERNAME="$2"; shift;;
    -u=*|--admin-user=*) SONAR_ADMIN_USERNAME="${1#*=}";;

    -s|--sonarqube) SONARQUBE_URL="$2"; shift;;
    -s=*|--sonarqube=*) SONARQUBE_URL="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then

    if [ -z "${SONARQUBE_URL}" ]; then
        SONARQUBE_URL=$(../scripts/get-config-param.sh SONARQUBE_URL)
    fi

    if [ -z "${SONAR_ADMIN_USERNAME}" ]; then
        SONAR_ADMIN_USERNAME=$(../scripts/get-config-param.sh SONAR_ADMIN_USERNAME)
    fi

    if [ -z "${SONAR_ADMIN_PASSWORD}" ]; then
        SONAR_ADMIN_PASSWORD=$(../scripts/get-config-param.sh SONAR_ADMIN_PASSWORD_B64 | base64 -d)
    fi

fi

Email_list=$( curl ${INSECURE} ${SONAR_URL}/api/users/search -u admin:${SONAR_ADMIN_TOKEN} | jq .users | grep login | grep @ | tr -d '"' | tr -d "," | cut -f2 -d ":" )
email_list_array=($Email_list)

for email in "${email_list_array[@]}"
do
    curl ${INSECURE} -X POST -sSf -u admin:${SONAR_ADMIN_TOKEN} "${SONAR_URL}/api/users/update_identity_provider?newExternalProvider=saml&login=${email}" > /dev/null
    echo "User ${email} migrated to Saml"
done
