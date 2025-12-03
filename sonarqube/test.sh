#!/usr/bin/env bash
# shellcheck source=/dev/null
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

SONAR_VERSION=2025.5.0
SONAR_EDITION="developer"

function usage {
    printf "Test SonarQube setup.\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-s|--sq-version\t\tSonarQube version, e.g. '2025.5.0' (defaults to %s)\n" "${SONAR_VERSION}"
    printf "\t-e|--sq-edition\t\tSonarQube edition, e.g. 'community' or 'enterprise' (defaults to %s)\n" "${SONAR_EDITION}"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\t--verify\t\tSkips setup of local docker container and instead checks existing sonarqube setup based on ods-core.env\n"
    printf "\t -n|--no-prompts\t\tDo not prompt for unknown passwords. Only used with --verify.\n"
    printf "\t -a|--admin-password\t\tUse given admin password. Only used with --verify.\n"
}

VERIFY_ONLY=false
ADMIN_PASSWORD=
PROMPTS=true
INSECURE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    --verify) VERIFY_ONLY=true;;

    -i|--insecure) INSECURE="--insecure";;

    -n|--no-prompts) PROMPTS=false;;

    -a|--admin-password) ADMIN_PASSWORD="$2"; shift;;
    -a=*|--admin-password=*) ADMIN_PASSWORD="${1#*=}";;

    -s|--sq-version) SONAR_VERSION="$2"; shift;;
    -s=*|--sq-version=*) SONAR_VERSION="${1#*=}";;

    -e|--sq-edition) SONAR_EDITION="$2"; shift;;
    -e=*|--sq-edition=*) SONAR_EDITION="${1#*=}";;

    *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${SONAR_VERSION}" ]; then
  echo "ERROR: Param --sq-version is missing!"; usage; exit 1;
fi

if [ -z "${SONAR_EDITION}" ]; then
  echo "ERROR: Param --sq-edition is missing!"; usage; exit 1;
fi

ADMIN_USER_DEFAULT_PASSWORD="admin"

if ! $VERIFY_ONLY; then

        HOST_PORT="9000"
        CONTAINER_IMAGE="sqtest"

        echo "Test proxy settings"
        rm test.properties || true
        sh -c "HTTP_PROXY=https://foo:bar@example.com:9000 ./docker/set-proxy.sh test.properties"
        if ! diff test.properties.fixture test.properties; then
            echo "Proxy settings mismatch"
            exit 1
        fi

        echo "Build image"
        docker build \
            -t "${CONTAINER_IMAGE}" \
            --build-arg sonarVersion="${SONAR_VERSION}" \
            --build-arg sonarEdition="${SONAR_EDITION}" \
            --build-arg idpDns="" \
            ./docker

        echo "Run container using image ${CONTAINER_IMAGE}"
        containerId=$(docker run -d --stop-timeout 3600 -p "${HOST_PORT}":9000 -p 9092:9092 "${CONTAINER_IMAGE}")

        function cleanup {
            echo "Cleanup"
            docker rm -f "${containerId}"
            rm test.properties
        }
        trap cleanup EXIT

        SONARQUBE_URL="http://localhost:${HOST_PORT}"
        SONAR_ADMIN_USERNAME="admin"
        ADMIN_USER_DEFAULT_PASSWORD="admin"
        ADMIN_PASSWORD="s3cr3t&C0mpl3x"
        PIPELINE_USER_NAME="cd_user"
        PIPELINE_USER_PWD="cd_user"

        echo "Wait for SonarQube to become healthy"
        set +e
        n=0
        until [ $n -ge 20 ]; do
            health=$(curl -sS ${INSECURE} --user "${SONAR_ADMIN_USERNAME}:${ADMIN_USER_DEFAULT_PASSWORD}" \
                "${SONARQUBE_URL}/api/system/health" | jq -r .health)
            if [ "${health}" == "GREEN" ]; then
                echo "SonarQube is up"
                break
            else
                echo "SonarQube is not up yet, waiting 10s ..."
                sleep 10s
                n=$((n+1))
            fi
        done
        set -e

        echo "Create fake cd_user"
        curl -X POST -sSf ${INSECURE} --user "${SONAR_ADMIN_USERNAME}:${ADMIN_USER_DEFAULT_PASSWORD}" \
            "${SONARQUBE_URL}/api/users/create?login=${PIPELINE_USER_NAME}&name=${PIPELINE_USER_NAME}&local=true&password=${PIPELINE_USER_PWD}" > /dev/null

        echo "Run ./configure.sh"
        prior_SONAR_AUTH_TOKEN_B64=
        if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
            prior_SONAR_AUTH_TOKEN_B64=$(grep SONAR_AUTH_TOKEN_B64 "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2-)
        fi
        ./configure.sh \
            --admin-password=${ADMIN_PASSWORD} \
            --pipeline-user=${PIPELINE_USER_NAME} \
            --sonarqube=${SONARQUBE_URL}
        now_SONAR_AUTH_TOKEN_B64=$(grep SONAR_AUTH_TOKEN_B64 "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2-)
        if [ -n "$now_SONAR_AUTH_TOKEN_B64" ] && [ "$now_SONAR_AUTH_TOKEN_B64" != "$prior_SONAR_AUTH_TOKEN_B64" ]; then
            SONAR_AUTH_TOKEN_B64="$now_SONAR_AUTH_TOKEN_B64"
        fi
else
    ods_core_env_file="${ODS_CONFIGURATION_DIR}/ods-core.env"
    if [ ! -f "$ods_core_env_file" ]; then
        echo "With --verify ods-core.env is used. However the file is not at $ods_core_env_file"
        exit 1
    fi
    # Now we read the SONARQUVE variables from ods-core.env
    # - Since we use set -u in this script undefined variables will
    #   cause the sscript to exit
    # - ods-core.env contains some passwords which makes a plain source
    #   hickup, therfore we are filtering this to only SONAR variables.
    grep SONAR "$ods_core_env_file" > verify-sonar.env
    source verify-sonar.env
    rm verify-sonar.env
    SONAR_ADMIN_USERNAME=${SONAR_ADMIN_USERNAME-"admin"}
    if [ -n "${SONAR_ADMIN_PASSWORD_B64-}" ]; then
        ADMIN_PASSWORD=$(echo -n "$SONAR_ADMIN_PASSWORD_B64" | base64 --decode)
    fi
    if $PROMPTS && [ -z "${ADMIN_PASSWORD}" ]; then
        echo "Please enter Sonarqube $SONAR_ADMIN_USERNAME password:"
        read -r -e -s input
        ADMIN_PASSWORD=${input:-""}
    fi
fi

echo "Check if login with default password is possible"
if curl -X POST ${INSECURE} -sSf \
    "${SONARQUBE_URL}/api/authentication/login?login=${SONAR_ADMIN_USERNAME}&password=${ADMIN_USER_DEFAULT_PASSWORD}"; then
    echo "Default password for '${SONAR_ADMIN_USERNAME}' has not been changed"
    exit 1
fi

if [ -n "${SONAR_AUTH_TOKEN_B64-}" ]; then
    CURL_ADMIN_AUTH="${SONAR_ADMIN_USERNAME}:${ADMIN_PASSWORD}"
    CURL_TOKEN_AUTH="$(echo -n "$SONAR_AUTH_TOKEN_B64" | base64 --decode):"
else
    CURL_ADMIN_AUTH="${SONAR_ADMIN_USERNAME}:${ADMIN_PASSWORD}"
fi

echo "Check if unauthenticated access is possible"
# Ideally we'd check a page that needs privileged access, but that always
# returns a loading page with status code 200. Therefore, we have to check for
# the value of the setting.
forceAuthentication=$(curl -sS ${INSECURE} \
    --user "${CURL_TOKEN_AUTH-$CURL_ADMIN_AUTH}" \
    "${SONARQUBE_URL}/api/settings/values?keys=sonar.forceAuthentication" | jq -r ".settings[0].value")
if [ "${forceAuthentication}" != "true" ]; then
    echo "sonar.forceAuthentication is not enabled"
    exit 1
fi

echo "Check if plugins are installed in correct versions"

case $SONAR_EDITION in

    community | developer | enterprise | datacenter)
        expectedPlugins=("groovy:1.8"
                "r:0.2.2")
        ;;

    *)
    echo -n "Sonar edition provided ${SONAR_EDITION} is not valid"; exit 1;;

esac

actualPlugins=$(curl -sSf ${INSECURE} \
    --user "$CURL_ADMIN_AUTH" \
    "${SONARQUBE_URL}/api/plugins/installed" | jq '.plugins')

for plugin in "${expectedPlugins[@]}"; do
    pluginName=${plugin%%:*}
    pluginVersion=${plugin#*:}
    actualVersion=$(echo "${actualPlugins}" | jq -r ".[] | select(.key == \"${pluginName}\") | .version")
    if [ "${actualVersion}" == "${pluginVersion}" ]; then
        echo "Plugin ${pluginName} has expected version ${pluginVersion}"
    else
        echo "Wrong ${pluginName} plugin version, want: ${pluginVersion}, got: ${actualVersion}"
        exit 1
    fi
done

echo "Check if system status is UP"
response=$(curl -sSf ${INSECURE} --user "${CURL_TOKEN_AUTH-$CURL_ADMIN_AUTH}" "${SONARQUBE_URL}/api/system/status")
systemUp=$(echo "$response" | jq ".status")
if [ "${systemUp}" == "\"UP\"" ]; then
    echo "Sonarcube system status is $systemUp"
else
    echo "system status reports $systemUp"
    echo "api response was: $response"
    exit 1
fi

echo "Success"
