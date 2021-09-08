#!/usr/bin/env bash
set -eu

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

BITBUCKET_URL=""
BITBUCKET_ODS_PROJECT="opendevstack"

function usage {
  printf "Initialise and update OpenDevStack configuration.\n\n"
  printf "Usage:\n\n"
  printf "\t-h|--help\t\tPrint usage\n"
  printf "\t-v|--verbose\t\tEnable verbose mode\n"
  printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
  printf "\t-p|--bitbucket-ods-project\tBitbucket ODS project, defaults to '%s'\n" "${BITBUCKET_ODS_PROJECT}"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -b|--bitbucket) BITBUCKET_URL="$2"; shift;;
  -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;

  -p|--bitbucket-ods-project) BITBUCKET_ODS_PROJECT="$2"; shift;;
  -p=*|--bitbucket-ods-project=*) BITBUCKET_ODS_PROJECT="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# Get directory of this script
WORKING_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ "$SCRIPT_DIR" == *ods-core/ods-setup ]]; then
  ODS_CORE_DIR=${SCRIPT_DIR%/*}
  WORKING_DIR=${ODS_CORE_DIR%/*}
fi

# Expected location of ods-configuration
REPO="ods-configuration"
GIT_REF="master"
SAMPLE_CONFIG_LOCATION="${ODS_CORE_DIR}/configuration-sample"
ACTUAL_CONFIG_LOCATION="${WORKING_DIR}/${REPO}"

echo_info "Checking if ${ACTUAL_CONFIG_LOCATION} exists."
if [ ! -d "${ACTUAL_CONFIG_LOCATION}" ]; then
  echo_info "Directory ${ACTUAL_CONFIG_LOCATION} does not exist yet."
  if [ -z ${BITBUCKET_URL} ]; then
    read -e -p "Enter your Bitbucket URL, e.g. 'https://bitbucket.example.com' (leave blank for initial setup): " input
    BITBUCKET_URL=${input:-""}
  fi
  if [ -z ${BITBUCKET_URL} ]; then
    echo_info "Creating ${REPO} from scratch."
    mkdir -p ${ACTUAL_CONFIG_LOCATION}
    cd ${ACTUAL_CONFIG_LOCATION} && git init && cd -
    echo_info "Created directory ${ACTUAL_CONFIG_LOCATION}."
  else
    echo_info "Cloning ${REPO} from Bitbucket."
    cd ${WORKING_DIR}
    git clone ${BITBUCKET_URL}/scm/${BITBUCKET_ODS_PROJECT}/${REPO}.git
  fi
else
  echo_info "Directory ${ACTUAL_CONFIG_LOCATION} exists already."
  cd ${ACTUAL_CONFIG_LOCATION}
  if ! git remote get-url origin &> /dev/null; then
    if [ -z ${BITBUCKET_URL} ]; then
      echo_warn "Remote 'origin' is missing.\n"
      configuredUrl="https://bitbucket.example.com"
      if [ -f "${ACTUAL_CONFIG_LOCATION}/ods-core.env" ]; then
          configuredUrl=$(../scripts/get-config-param.sh BITBUCKET_URL)
      fi
      read -e -p "Enter your Bitbucket URL [${configuredUrl}]: " input
      if [ -z "${input}" ]; then
        BITBUCKET_URL=${configuredUrl}
      else
        BITBUCKET_URL="${input}"
      fi
    fi
    BITBUCKET_REPO="${BITBUCKET_URL}/scm/${BITBUCKET_ODS_PROJECT}/${REPO}.git"
    echo_info "Adding remote 'origin' (${BITBUCKET_REPO})."
    git remote add origin ${BITBUCKET_REPO}
  fi
  echo_info "Fetching from remote 'origin'."
  git fetch origin
  if ! git checkout ${GIT_REF}; then
    echo_error "origin/${GIT_REF} cannot be checked out, which means that your local state has modifications. Please clean your local state."
    exit 1
  fi
  if ! git merge origin/${GIT_REF}; then
    echo_error "origin/${GIT_REF} cannot be merged, which means the ref on Bitbucket has been modified. Please reset your local ref to origin/${GIT_REF}."
    exit 1
  fi
  cd - &> /dev/null
fi

echo ""

cd ${SAMPLE_CONFIG_LOCATION}

echo_info "Updating .env.sample files ..."
cp *.env.sample ${ACTUAL_CONFIG_LOCATION}/
echo_info ".env.sample files updated."

echo ""

echo_info "Checking for missing params in .env files ... "
cd ${ACTUAL_CONFIG_LOCATION}
elementIn() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}
anyDrift=false
for i in *.env.sample; do
  actualFile="${i%%.sample}"
  if [ ! -f "${actualFile}" ]; then
    echo_warn "Actual param file ${actualFile} does not exist yet and will be created. Please review its contents carefully."
    cp $i $actualFile
  else
    sampleParams=$(cat $i | grep "^[A-Z1-9_]\+=" | awk -F'=' '{print $1}')
    actualParams=($(cat $actualFile | grep "^[A-Z1-9_]\+=" | awk -F'=' '{print $1"="}'))
    for sampleParam in $sampleParams; do
      if ! (elementIn "${sampleParam}=" "${actualParams[@]}"); then
        anyDrift=true
        echo_warn "${sampleParam} is present in ${i}, but not in ${actualFile}. Please add it."
      fi
    done
  fi
done
if [ "${anyDrift}" = false ] ; then
  echo_done "All params in .env.sample files are present in their counterpart .env files."
else
  echo_error "Not all params in .env.samplple files are present in their counterpart .env files."
  exit 1
fi
