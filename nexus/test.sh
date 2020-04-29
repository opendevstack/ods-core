
#!/usr/bin/env bash
set -ue

NEXUS_VERSION=3.22.0

function usage {
    printf "Test Nexus setup.\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-s|--nexus-version\t\tNexus version, e.g. '3.22.0' (defaults to ${NEXUS_VERSION})\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -s|--nexus-version) NEXUS_VERSION="$2"; shift;;
    -s=*|--nexus-version=*) NEXUS_VERSION="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

CONTAINER_IMAGE="sonatype/nexus3:${NEXUS_VERSION}"
HOST_PORT="8081"

echo "Run container using image ${CONTAINER_IMAGE}"
containerId=$(docker run -d -p ${HOST_PORT}:8081 ${CONTAINER_IMAGE})

function cleanup {
    echo "Cleanup"
    docker rm -f ${containerId}
}
trap cleanup EXIT

NEXUS_URL="http://localhost:${HOST_PORT}"
ADMIN_USER_NAME=admin
ADMIN_USER_PWD=s3cr3t
DEV_USER_NAME=developer
DEV_USER_PWD=geHeim

echo "Run ./configure.sh"
./configure.sh \
    --admin-password=${ADMIN_USER_PWD} \
    --developer-password=${DEV_USER_PWD} \
    --nexus=${NEXUS_URL} \
    --local-container-id=${containerId}

echo "Check for blobstores"
expectedBlobstores=( "candidates"
                     "releases"
                     "atlassian_public"
                     "npm-private"
                     "pypi-private"
                     "leva-documentation" )

actualBlobstores=$(curl \
    --fail \
    --silent \
    --user ${ADMIN_USER_NAME}:${ADMIN_USER_PWD} \
    ${NEXUS_URL}/service/rest/beta/blobstores)

for blobstore in "${expectedBlobstores[@]}"; do
    if echo ${actualBlobstores} | jq -e ".[] | select(.name == \"${blobstore}\")" > /dev/null; then
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
                "npm-all:group"
                "pypi-registry:proxy"
                "pypi-private:hosted"
                "pypi-all:group"
                "leva-documentation:hosted")

actualRepos=$(curl \
    --fail \
    --silent \
    --user ${ADMIN_USER_NAME}:${ADMIN_USER_PWD} \
    ${NEXUS_URL}/service/rest/v1/repositories)

for repo in "${expectedRepos[@]}"; do
    repoName=${repo%%:*}
    repoType=${repo#*:}
    if echo ${actualRepos} | jq -e ".[] | select(.name == \"${repoName}\")" > /dev/null; then
        actualType=$(echo ${actualRepos} | jq -r ".[] | select(.name == \"${repoName}\") | .type")
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
visibleRepos=$(curl --fail --silent ${NEXUS_URL}/service/rest/v1/repositories | jq -e "length > 0")
if [ "${visibleRepos}" == "true" ]; then
    echo "Anonymous access still possible"
    exit 1
else
    echo "Anonymous access is disabled"
fi

echo "Check developer access"
visibleRepos=$(curl --fail --silent \
    -u ${DEV_USER_NAME}:${DEV_USER_PWD} \
    ${NEXUS_URL}/service/rest/v1/repositories | jq -e "length > 0")
if [ "${visibleRepos}" == "false" ]; then
    echo "Developer access not possible"
    exit 1
else
    echo "Developer access possible"
fi

echo "Success"
