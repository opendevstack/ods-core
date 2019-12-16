#!/usr/bin/env bash
set -xe

function usage() {

  exit
}
TAILOR=tailor
TAILOR_FOLDER="${BASH_SOURCE%/*}/ocp-config/cd-user"
echo "${BASH_SOURCE%/*}/"

while [ "$1" != "" ]; do
  case $1 in
  -e | --ods-core-env)
    shift
    ODS_CORE_ENV=$1
    ;;
  -t | --tailor)
    shift
    TAILOR=$1
    ;;
  -h | --help)
    usage
    exit
    ;;
  *)
    usage
    exit 1
    ;;
  esac
  shift
done

if [[ -z "${ODS_CORE_ENV}" && ! -f "${ODS_CORE_ENV}" ]]; then
  echo "--ods-core-env must be provided and pointing to a existing file"
  usage
fi

if [[ ! -f "${SECRET_TEMPLATE}" ]]; then
  echo "--secret-template must pointing to a existing file"
  usage
fi


if ! oc whoami; then
  echo "You shoul be logged to run the script"
  exit 1
fi

if oc project cd; then
  echo "The Project CD already exists"
  exit 1
fi

oc new-project cd --description="Base project holding the templates and the Repositoy Manager" --display-name="OpenDevStack Templates"

# Allow system:authenticated group to pull images from CD namespace
oc adm policy add-cluster-role-to-group system:image-puller system:authenticated -n cd
oc adm policy add-role-to-group view system:authenticated -n cd

oc create sa deployment -n cd
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:cd:deployment

# create secrets for global cd_user
cd "${TAILOR_FOLDER}"
${TAILOR}
