#!/usr/bin/env bash
# shellcheck source=/dev/null
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

NEXUS_VERSION="3.22.0"

function usage {
    printf "Test Nexus setup.\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t--verify\t\tSkips setup of local docker container and instead checks existing nexus setup based on ods-core.env\n"
    printf "\t-n|--no-prompts\t\tDo not prompt for passwords which were not passed in.\n"
    printf "\t-a|--admin-password\t\tUse given admin password.\n"
    printf "\t-d|--developer-password\t\tUse given developer password.\n"
    printf "\t-s|--nexus-version\t\tNexus version, e.g. '3.22.0' (defaults to %s)\n" "${NEXUS_VERSION}"
}

VERIFY_ONLY=false
ADMIN_PASSWORD=
DEVELOPER_PASSWORD=
PROMPTS=true
while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    --verify) VERIFY_ONLY=true;;

    -n|--no-prompts) PROMPTS=false;;

    -a|--admin-password) ADMIN_PASSWORD="$2"; shift;;
    -a=*|--admin-password=*) ADMIN_PASSWORD="${1#*=}";;

    -d|--developer-password) DEVELOPER_PASSWORD="$2"; shift;;
    -d=*|--developer-password=*) DEVELOPER_PASSWORD="${1#*=}";;

    -s|--nexus-version) NEXUS_VERSION="$2"; shift;;
    -s=*|--nexus-version=*) NEXUS_VERSION="${1#*=}";;

    *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! $VERIFY_ONLY; then
    CONTAINER_IMAGE="sonatype/nexus3:${NEXUS_VERSION}"
    HOST_PORT="8081"

    HTTP_PROXY="someproxy.local"
    HTTPS_PROXY="someproxy.local:99"
    NO_PROXY=".local,.svc"

    echo "Run container using image ${CONTAINER_IMAGE}"
    containerId=$(docker run -d -p "${HOST_PORT}:8081" -e HTTP_PROXY="${HTTP_PROXY}" -e HTTPS_PROXY="${HTTPS_PROXY}" -e NO_PROXY="${NO_PROXY}" "${CONTAINER_IMAGE}")

    function cleanup {
        echo "Cleanup"
        docker rm -f "${containerId}"
    }
    trap cleanup EXIT

    NEXUS_URL="http://localhost:${HOST_PORT}"
    NEXUS_ADMIN_USERNAME="admin"
    NEXUS_ADMIN_PASSWORD=${ADMIN_PASSWORD:-"s3cr3t"}
    NEXUS_USERNAME="developer"
    NEXUS_PASSWORD=${DEVELOPER_PASSWORD:-"geHeim"}

    echo "Run ./configure.sh"
    ./configure.sh \
        --admin-password="${NEXUS_ADMIN_PASSWORD}" \
        --developer-password="${NEXUS_PASSWORD}" \
        --nexus="${NEXUS_URL}" \
        --local-container-id="${containerId}"
else
    ods_core_env_file="${ODS_CONFIGURATION_DIR}/ods-core.env"
    if [ ! -f "$ods_core_env_file" ]; then
        echo "With --verify ods-core.env is used. However the file is not at $ods_core_env_file"
        exit 1
    fi
    # Now we read the NEXUS variables from ods-core.env
    # - Since we use set -u in this script undefined variables will
    #   cause the sscript to exit
    # - ods-core.env contains some passwords which makes a plain source
    #   hickup, therfore we are filtering this to only NEXUS variables.
    source <( grep NEXUS "$ods_core_env_file")

    NEXUS_USERNAME=${NEXUS_USERNAME-"developer"}
    NEXUS_ADMIN_USERNAME=${NEXUS_ADMIN_USERNAME-"admin"}
    if $PROMPTS; then
        if [ -z "${ADMIN_PASSWORD}" ] && [ -z "${NEXUS_ADMIN_PASSWORD-}" ]; then
            echo "Please enter Nexus $NEXUS_ADMIN_USERNAME password:"
            read -r -e -s input
            NEXUS_ADMIN_PASSWORD=${input:-""}
        fi
        if [ -z "${DEVELOPER_PASSWORD}" ] && [ -z "${NEXUS_PASSWORD-}" ]; then
            echo "Please enter Nexus $NEXUS_USERNAME password:"
            read -r -e -s input
            NEXUS_PASSWORD=${input:-""}
        fi
    fi
fi

if [ -n "${NEXUS_ADMIN_PASSWORD-}" ]; then
    echo "Check for blobstores"
    expectedBlobstores=( "candidates"
                        "releases"
                        "atlassian_public"
                        "npm-private"
                        "pypi-private"
                        "leva-documentation" )

    actualBlobstores=$(curl -sSf \
        --user "${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD}" \
        ${NEXUS_URL}/service/rest/beta/blobstores)

    for blobstore in "${expectedBlobstores[@]}"; do
        if echo "${actualBlobstores}" | jq -e ".[] | select(.name == \"${blobstore}\")" > /dev/null; then
            echo "Blobstore '${blobstore}' is available"
        else
            echo "Blobstore '${blobstore}' is missing"
            exit 1
        fi
    done

    echo "Check for repositories"
    expectedRepos=( "candidates:hosted"
                    "releases:hosted"
                    "atlassian_public:proxy"
                    "jcenter:proxy"
                    "jenkins-ci-releases:proxy"
                    "sbt-plugins:proxy"
                    "sbt-releases:proxy"
                    "typesafe-ivy-releases:proxy"
                    "ivy-releases:group"
                    "npm-registry:proxy"
                    "npm-private:hosted"
                    "pypi-registry:proxy"
                    "pypi-private:hosted"
                    "pypi-all:group"
                    "leva-documentation:hosted")

    actualRepos=$(curl -sSf \
        --user "${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD}" \
        ${NEXUS_URL}/service/rest/v1/repositories)

    for repo in "${expectedRepos[@]}"; do
        repoName=${repo%%:*}
        repoType=${repo#*:}
        if echo "${actualRepos}" | jq -e ".[] | select(.name == \"${repoName}\")" > /dev/null; then
            actualType=$(echo "${actualRepos}" | jq -r ".[] | select(.name == \"${repoName}\") | .type")
            if [ "${actualType}" == "${repoType}" ]; then
                echo "Repo '${repoName}' is available and has expected type '${repoType}'"
            else
                echo "Repo '${repoName}' is available, but has wrong type. Want: '${repoType}', got: '${actualType}'"
                exit 1
            fi
        else
            echo "Repo '${repoName}' is missing"
            exit 1
        fi
    done
else
    echo "Skip checking for blobstores and repositories. This requires an admin password."
    echo "  See help on how to specify the admin-password."
    echo "  Alternatively env variable NEXUS_ADMIN_PASSWORD can be set or stored in ods-core.env"
fi

echo "Check if anonymous access is still possible"
if curl -sSf \
    ${NEXUS_URL}/service/rest/v1/repositories | jq -e "length > 0" > /dev/null; then
    echo "Anonymous access still possible"
    exit 1
else
    echo "Anonymous access is disabled"
fi

echo "Check developer access"
if curl -sSf \
    --user "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" \
    ${NEXUS_URL}/service/rest/v1/repositories | jq -e "length == 0" > /dev/null; then
    echo "Developer access not possible"
    exit 1
else
    echo "Developer access possible"
fi


artifact_url="${NEXUS_URL}/repository/jcenter/org/springframework/boot/spring-boot/2.3.0.RELEASE/spring-boot-2.3.0.RELEASE.pom"

echo "Downloading sample artifact: $artifact_url"
# retrieves an xml doc.
http_code=$(curl -sSf --location -o /dev/null -w "%{http_code}" \
    --user "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" \
    "$artifact_url")
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "curl exit code $exit_code"
    exit 1
fi
if [ "$http_code" -ne 200 ]; then
    echo "http code not OK: $http_code"
    exit 1
fi
echo "Downloading sample artifact succeeded."

echo "Success"
