
#!/usr/bin/env bash
set -ue

echo_done(){
  echo "\033[92mDONE\033[39m: $1"
}

echo_error(){
  echo "\033[31mERROR\033[39m: $1"
}

echo_info(){
  echo "\033[94mINFO\033[39m: $1"
}

CONFIRM=
BITBUCKET_URL=
GIT_REF=
PUSH=

function usage {
  printf "Initialise, update and sync OpenDevStack repositories.\n\n"
  printf "This script will ask interactively for parameters by default.\n"
  printf "However, you can also pass them directly. Usage:\n\n"
  printf "\t-h|--help\t\tPrint usage\n"
  printf "\t-v|--verbose\t\tEnable verbose mode\n"
  printf "\t--confirm\t\tDon't ask for confirmation\n"
  printf "\t--push\t\t\tPush Git Ref to BitBucket\n"
  printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
  printf "\t-g|--git-ref\t\tGit ref, e.g. '2.x' or 'master'\n"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --confirm) CONFIRM="y";;

  --push) PUSH="y";;

  -b|--bitbucket) BITBUCKET_URL="$2"; shift;;
  -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;

  -g|--git-ref) GIT_REF="$2"; shift;;
  -g=*|--git-ref=*) GIT_REF="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

WORKING_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ "$SCRIPT_DIR" == *ods-core/ods-setup ]]; then
  ODS_CORE_DIR=${SCRIPT_DIR%/*}
  WORKING_DIR=${ODS_CORE_DIR%/*}
fi

if [ -z ${CONFIRM} ]; then
  read -e -p "Repositories will be located in ${WORKING_DIR}. Continue? [y/n] " input
  CONFIRM=${input:-""}
fi
if [ "$CONFIRM" != "y" ]; then
  exit 1
fi
cd ${WORKING_DIR}

if [ -z ${BITBUCKET_URL} ]; then
  read -e -p "Enter your BitBucket base URL, e.g. 'https://bitbucket.example.com': " input
  BITBUCKET_URL=${input:-""}
fi
if [ -z ${BITBUCKET_URL} ]; then
  echo_error "BitBucket base URL cannot be empty.";
  exit 1;
else
  echo_info "BitBucket is set to ${BITBUCKET_URL}."
fi

if [ -z ${GIT_REF} ]; then
  read -e -p "Enter the Git ref to checkout, e.g. '2.x' or 'master': " input
  GIT_REF=${input:-""}
fi
if [ -z ${GIT_REF} ]; then
  echo_error "Git ref cannot be empty.";
  exit 1;
else
  echo_info "Repos will be checked out @ ods/${GIT_REF}."
fi

if [ -z ${PUSH} ]; then
  read -e -p "Do you want to push ods/${GIT_REF} to your BitBucket server? [y/n] " input
  PUSH=${input:-""}
fi
if [ "$PUSH" == "y" ]; then
  echo_info "ods/${GIT_REF} will be pushed to BitBucket.";
else
  echo_info "No refs will be pushed to BitBucket.";
fi

OPENDEVSTACK_ORG="opendevstack"
GITHUB_URL="https://github.com"

for REPO in ods-core ods-quickstarters ods-jenkins-shared-library ods-mro-jenkins-shared-library ods-provisioning-app; do
  echo_info "Preparing ${REPO}."
  BITBUCKET_REPO="${BITBUCKET_URL}/scm/${OPENDEVSTACK_ORG}/${REPO}.git"
  GITHUB_REPO="${GITHUB_URL}/${OPENDEVSTACK_ORG}/${REPO}.git"

  if [ -d "${REPO}" ] ; then
    echo_info "Directory ${REPO} exists already."
  else
    echo_info "Directory ${REPO} does not exist yet."
    if git ls-remote ${BITBUCKET_REPO} &> /dev/null; then
      echo_info "${REPO} is reachable on Bitbucket, cloning from there."
      git clone ${BITBUCKET_REPO}
      cd ${REPO}
      echo_info "Adding remote 'ods' (${GITHUB_REPO})."
      git remote add ods ${GITHUB_REPO}
      cd -  &> /dev/null
    else
      echo_info "${REPO} is not reachable on Bitbucket, cloning from GitHub."
      git clone --origin ods ${GITHUB_REPO}
      cd ${REPO}
      echo_info "Adding remote 'origin' (${GITHUB_REPO})."
      git remote add origin ${BITBUCKET_REPO}
      cd -  &> /dev/null
    fi
  fi

  # repo directory exists now
  cd ${REPO}
  # update remotes
  echo_info "Fetching from 'origin'."
  git fetch origin
  if ! git remote get-url ods &> /dev/null; then
    echo_info "Remote 'ods' does not exist yet, adding it (${GITHUB_REPO})."
    git remote add ods ${GITHUB_REPO}
  fi
  echo_info "Fetching from 'ods'."
  git fetch ods
  # update ref
  if git rev-parse ${GIT_REF} &> /dev/null; then
    echo_info "Checking out existing local ref '${GIT_REF}'."
    if ! git checkout ${GIT_REF}; then
      echo_error "ods/${GIT_REF} cannot be checked out, which means that it has modifications. Please reset your local ref to ods/${GIT_REF}."
      exit 1
    fi
    echo_info "Merging 'ods/${GIT_REF}' into local ref."
    if ! git merge ods/${GIT_REF}; then
      echo_error "ods/${GIT_REF} cannot be merged, which means the ref on BitBucket has been modified. Please reset your local ref to ods/${GIT_REF}."
      exit 1
    fi
    if [ "$(git rev-parse ${GIT_REF})" != $(git rev-parse ods/${GIT_REF}) ]; then
      echo_error "${GIT_REF} differs from ods/${GIT_REF}. Please reset your local ref to ods/${GIT_REF}."
      exit 1
    fi
  else
    echo_info "Creating local ref '${GIT_REF}'."
    git checkout -b ${GIT_REF} ods/${GIT_REF} --no-track
    git branch --set-upstream-to origin/${GIT_REF}
  fi
  echo_done "Prepared ${REPO}."
  if [ "$PUSH" == "y" ]; then
    echo_info "Pushing '${GIT_REF}' to BitBucket."
    git push origin ${GIT_REF}
    echo_done "Pushed '${GIT_REF}' to BitBucket."
  fi
  cd - &> /dev/null
  echo ""

done
