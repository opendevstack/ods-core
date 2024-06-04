#!/usr/bin/env bash
# shellcheck source=/dev/null
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

NEXUS_IMAGE=$("${ODS_CORE_DIR}"/scripts/get-sample-param.sh NEXUS_IMAGE_TAG)

function usage {
    printf "Test Nexus setup.\n\n"
    printf "\t-h|--help\t\t\tPrint usage\n"
    printf "\t-v|--verbose\t\t\tEnable verbose mode\n"
    printf "\t--verify\t\t\tSkips setup of local docker container and instead checks existing nexus setup based on ods-core.env\n"
    printf "\t-n|--no-prompts\t\t\tDo not prompt for passwords which were not passed in.\n"
    printf "\t-a|--admin-password\t\tUse given admin password.\n"
    printf "\t-d|--developer-password\t\tUse given developer password.\n"
    printf "\t-s|--nexus-image\t\tNexus image (defaults to: %s)\n" "${NEXUS_IMAGE}"
    printf "\t-i|--insecure\t\t\tAllow insecure server connections when using SSL\n"
}

VERIFY_ONLY=false
ADMIN_PASSWORD=
DEVELOPER_PASSWORD=
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

    -d|--developer-password) DEVELOPER_PASSWORD="$2"; shift;;
    -d=*|--developer-password=*) DEVELOPER_PASSWORD="${1#*=}";;

    -s|--nexus-image) NEXUS_IMAGE="$2"; shift;;
    -s=*|--nexus-image=*) NEXUS_IMAGE="${1#*=}";;

    *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! $VERIFY_ONLY; then
    HOST_PORT="8081"

    # HTTP_PROXY="someproxy.local"
    HTTP_PROXY=
    # HTTPS_PROXY="someproxy.local:99"
    HTTPS_PROXY=
    # NO_PROXY=".local,.svc"
    NO_PROXY=

    echo "Run container using image ${NEXUS_IMAGE}"
    containerId=$(docker run -d -p "${HOST_PORT}:8081" -e HTTP_PROXY="${HTTP_PROXY}" -e HTTPS_PROXY="${HTTPS_PROXY}" -e NO_PROXY="${NO_PROXY}" "sonatype/nexus3:${NEXUS_IMAGE}")

    function cleanup {
        echo "Cleanup"
        docker rm -f "${containerId}"
    }
    trap cleanup EXIT

    NEXUS_URL="http://localhost:${HOST_PORT}"
    NEXUS_ADMIN_USERNAME="admin"
    NEXUS_ADMIN_PASSWORD=${ADMIN_PASSWORD:-"s3cr3t"}

    echo "Run configure.sh"
    "${SCRIPT_DIR}"/configure.sh \
        --admin-password="${NEXUS_ADMIN_PASSWORD}" \
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
    #   cause the script to exit
    # - ods-core.env contains some passwords which makes a plain source
    #   hickup, therfore we are filtering this to only NEXUS variables.
    grep NEXUS "$ods_core_env_file" > verify-nexus.env
    source verify-nexus.env
    rm verify-nexus.env

    NEXUS_ADMIN_USERNAME=${NEXUS_ADMIN_USERNAME-"admin"}
    if $PROMPTS; then
        if [ -z "${ADMIN_PASSWORD}" ] && [ -z "${NEXUS_ADMIN_PASSWORD-}" ]; then
            echo "Please enter Nexus $NEXUS_ADMIN_USERNAME password:"
            read -r -e -s input
            NEXUS_ADMIN_PASSWORD=${input:-""}
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

    actualBlobstores=$(curl -sSf ${INSECURE} \
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
else
    echo "Skip checking for blobstores. This requires an admin password."
    echo "  See help on how to specify the admin-password."
    echo "  Alternatively env variable NEXUS_ADMIN_PASSWORD can be set or stored in ods-core.env"
fi

echo "Check for repositories"
expectedRepos=( "candidates:hosted"
                "releases:hosted"
                "atlassian_public:proxy"
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

actualRepos=$(curl -sSf ${INSECURE} \
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

echo "Check if anonymous access is still possible"
if curl -sSf ${INSECURE} \
    ${NEXUS_URL}/service/rest/v1/repositories | jq -e "length > 0" > /dev/null; then
    echo "Anonymous access still possible"
    exit 1
else
    echo "Anonymous access is disabled"
fi

artifact_url="${NEXUS_URL}/repository/maven-public/org/springframework/boot/spring-boot/2.3.0.RELEASE/spring-boot-2.3.0.RELEASE.pom"

echo "Downloading sample artifact: $artifact_url"
# retrieves an xml doc.
http_code=$(curl -sSf ${INSECURE} --location -o /dev/null -w "%{http_code}" \
    --user "${NEXUS_ADMIN_USERNAME}:${NEXUS_ADMIN_PASSWORD}" \
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
