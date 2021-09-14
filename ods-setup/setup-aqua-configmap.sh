#!/usr/bin/env bash

# Create the namespace for holding all ODS resources

set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAILOR="tailor"
NAMESPACE="ods"
NON_INTERACTIVE=""
REVEAL_SECRETS=""

function usage {
  printf "usage: %s [options]\n" $0
  printf "\t--non-interactive\tDon't ask for user confirmation\n"
  printf "\t--reveal-secrets\tShow secrets (base64) in diff\n"
  printf "\t-h|--help\tPrint usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-t|--tailor\tChange executable of tailor. Default: ${TAILOR}\n"
  printf "\t-n|--namespace\tNamespace. Default: ${NAMESPACE}\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --non-interactive) NON_INTERACTIVE="--non-interactive"; ;;

  --reveal-secrets) REVEAL_SECRETS="--reveal-secrets"; ;;

  -t=*|--tailor=*) TAILOR="${1#*=}";;
  -t|--tailor) TAILOR="$2"; shift;;

  -n=*|--namespace=*) NAMESPACE="${1#*=}";;
  -n|--namespace) NAMESPACE="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if ! oc whoami > /dev/null; then
  echo "You must be logged into OpenShift to run this script"
  exit 1
fi


# Create aqua configmap
cd ${SCRIPT_DIR}/ocp-config/aqua
${TAILOR} -n ${NAMESPACE} apply ${NON_INTERACTIVE} ${REVEAL_SECRETS}
cd -

echo "Done"
