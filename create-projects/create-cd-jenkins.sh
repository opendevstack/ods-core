#!/usr/bin/env bash
set -eux

# This script sets up the cd/jenkins-master and the associated webhook proxy.

# support pointing to patched tailor using TAILOR environment variable
: ${TAILOR:=tailor}

tailor_exe=$(type -P ${TAILOR})
tailor_version=$(${TAILOR} version)

echo "Using tailor ${tailor_version} from ${tailor_exe}"

echo env

DEBUG=false
STATUS=false
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --status)
    STATUS=true
    ;;
    -d|--debug)
    DEBUG=true;
    shift
    ;;
    *)
        echo "Unknown option: $1. Exiting."
        exit 1
    ;;
esac
shift # past argument or value
done

if $DEBUG; then
  tailor_verbose="-v"
else
  tailor_verbose=""
fi

tailor_verbose+=" --force"

if [ -z ${PROJECT_ID+x} ]; then
    echo "PROJECT_ID is unset, but required";
    exit 1;
else echo "PROJECT_ID=${PROJECT_ID}"; fi

if $STATUS; then
  echo "NOTE: Invoked with --status:  will use tailor status instead of tailor update."
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tailor_update_in_dir() {
    local dir="$1"; shift
    if [ ${STATUS} = "true" ]; then
        $DEBUG && echo 'exec:' cd  "$dir" '&&'
        $DEBUG && echo 'exec:'     ${TAILOR} $tailor_verbose status "$@"
        cd "$dir" && ${TAILOR} $tailor_verbose status "$@"
    else
        $DEBUG && echo 'exec:' cd "$dir" '&&'
        $DEBUG && echo 'exec:    ' ${TAILOR} $tailor_verbose --non-interactive update "$@"
        cd "$dir" && ${TAILOR} $tailor_verbose --non-interactive update "$@"
    fi
}

tailor_update_in_dir "${SCRIPT_DIR}/ocp-config/cd-jenkins" \
    "--namespace=${PROJECT_ID}-cd" \
    "--param=PROXY_TRIGGER_SECRET_B64=${PIPELINE_TRIGGER_SECRET}" \
    "--param=PROJECT=${PROJECT_ID}" \
    "--param=CD_USER_ID_B64=${CD_USER_ID_B64}" \
    "--param=NEXUS_USERNAME=${NEXUS_USERNAME}" \
    "--param=NEXUS_PASSWORD_B64=${NEXUS_PASSWORD_B64}" \
    --selector "template=cd-jenkins-template"

# add secrets for dockerfile build to dev and test
for devenv in dev test ; do
    tailor_update_in_dir "${SCRIPT_DIR}/ocp-config/cd-user" \
        "--namespace=${PROJECT_ID}-${devenv}" \
        "--param=CD_USER_ID_B64=${CD_USER_ID_B64}" 
done
