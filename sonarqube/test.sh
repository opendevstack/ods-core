#!/usr/bin/env bash
set -ue

SONAR_VERSION=

function usage {
    printf "Test SonarQube setup.\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-s|--sq-version\t\tSonarQube version, e.g. '7.9' or '8.2.0.32929'\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -s|--sq-version) SONAR_VERSION="$2"; shift;;
    -s=*|--sq-version=*) SONAR_VERSION="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${SONAR_VERSION}" ]; then
  echo "ERROR: Param --sq-version is missing!"; usage; exit 1;
fi

SONAR_DISTRIBUTION_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"
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
    --build-arg sonarDistributionUrl="${SONAR_DISTRIBUTION_URL}" \
    --build-arg sonarVersion="${SONAR_VERSION}" \
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
ADMIN_USER_NAME="admin"
ADMIN_USER_DEFAULT_PASSWORD="admin"
ADMIN_USER_PWD="s3cr3t"
PIPELINE_USER_NAME="cd_user"
PIPELINE_USER_PWD="cd_user"

echo "Wait for SonarQube to become healthy"
set +e
n=0
until [ $n -ge 20 ]; do
    health=$(curl -sS --user "${ADMIN_USER_NAME}:${ADMIN_USER_DEFAULT_PASSWORD}" \
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
curl -X POST -sSf --user "${ADMIN_USER_NAME}:${ADMIN_USER_DEFAULT_PASSWORD}" \
    "${SONARQUBE_URL}/api/users/create?login=${PIPELINE_USER_NAME}&name=${PIPELINE_USER_NAME}&local=true&password=${PIPELINE_USER_PWD}" > /dev/null

echo "Run ./configure.sh"
./configure.sh \
    --admin-password=s3cr3t \
    --pipeline-user=${PIPELINE_USER_NAME} \
    --sonarqube=${SONARQUBE_URL}

echo "Check if login with default password is possible"
if curl -X POST -sSf \
    "${SONARQUBE_URL}/api/authentication/login?login=${ADMIN_USER_NAME}&password=${ADMIN_USER_DEFAULT_PASSWORD}"; then
    echo "Default password for '${ADMIN_USER_NAME}' has not been changed"
    exit 1
fi

echo "Check if unauthenticated access is possible"
# Ideally we'd check a page that needs privileged access, but that always
# returns a loading page with status code 200. Therefore, we have to check for
# the value of the setting.
forceAuthentication=$(curl -sS \
    --user ${ADMIN_USER_NAME}:${ADMIN_USER_PWD} \
    "${SONARQUBE_URL}/api/settings/values?keys=sonar.forceAuthentication" | jq -r ".settings[0].value")
if [ "${forceAuthentication}" != "true" ]; then
    echo "sonar.forceAuthentication is not enabled"
    exit 1
fi

echo "Check if plugins are installed in correct versions"
expectedPlugins=( "crowd:2.1.3"
                  "authoidc:1.1.0"
                  "scmgit:1.9.1.1834"
                  "java:6.2.0.21135"
                  "jacoco:1.0.2.475"
                  "go:1.6.0.719"
                  "javascript:6.1.0.11503"
                  "python:2.1.0.5269"
                  "typescript:2.1.0.4359"
                  "sonarscala:1.5.0.315"
                  "php:3.3.0.5166"
                  "csharp:8.6.1.17183"
                  "groovy:1.6" )

actualPlugins=$(curl -sSf \
    --user ${ADMIN_USER_NAME}:${ADMIN_USER_PWD} \
    "${SONARQUBE_URL}/api/system/info" | jq '.Statistics.plugins')

for plugin in "${expectedPlugins[@]}"; do
    pluginName=${plugin%%:*}
    pluginVersion=${plugin#*:}
    actualVersion=$(echo "${actualPlugins}" | jq -r ".[] | select(.name == \"${pluginName}\") | .version")
    if [ "${actualVersion}" == "${pluginVersion}" ]; then
        echo "Plugin ${pluginName} has expected version ${pluginVersion}"
    else
        echo "Wrong ${pluginName} plugin version, want: ${pluginVersion}, got: ${actualVersion}"
        exit 1
    fi
done

echo "Success"
