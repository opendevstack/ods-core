
#!/usr/bin/env bash
set -ue

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

INIT=n
CONFIRM=
BITBUCKET_URL=
GIT_REF=
SYNC=n

function usage {
  printf "Initialise, update and sync OpenDevStack repositories.\n\n"
  printf "This script will ask interactively for parameters by default.\n"
  printf "However, you can also pass them directly. Usage:\n\n"
  printf "\t-h|--help\t\tPrint usage\n"
  printf "\t-v|--verbose\t\tEnable verbose mode\n"
  printf "\t--confirm\t\tDon't ask for confirmation\n"
  printf "\t--init\t\t\tDo not assume an existing Bitbucket server\n"
  printf "\t--sync\t\t\tPull refs from GitHub and push refs to Bitbucket\n"
  printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
  printf "\t-g|--git-ref\t\tGit ref, e.g. '2.x' or 'master'\n"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --confirm) CONFIRM="y";;

  --sync) SYNC="y";;

  --init) INIT="y";;

  -b|--bitbucket) BITBUCKET_URL="$2"; shift;;
  -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;

  -g|--git-ref) GIT_REF="$2"; shift;;
  -g=*|--git-ref=*) GIT_REF="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# Use either current directory, or the parent directory of ods-core as the
# working directory.
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

if [ ! -z ${BITBUCKET_URL} ]; then
  echo_info "Bitbucket is set to ${BITBUCKET_URL}."
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

if [ -z ${SYNC} ]; then
  read -e -p "Do you want to push ods/${GIT_REF} to your Bitbucket server? [y/n] " input
  SYNC=${input:-""}
fi
if [ "$SYNC" == "y" ]; then
  echo_info "ods/${GIT_REF} will be pushed to Bitbucket.";
else
  echo_info "No refs will be pushed to Bitbucket.";
fi

OPENDEVSTACK_ORG="opendevstack"
GITHUB_URL="https://github.com"

for REPO in ods-core ods-quickstarters ods-jenkins-shared-library ods-provisioning-app; do
  echo_info "Preparing ${REPO}."
  GITHUB_REPO="${GITHUB_URL}/${OPENDEVSTACK_ORG}/${REPO}.git"

  if [ -d "${REPO}" ] ; then
    echo_info "Directory ${REPO} exists already."
  else
    echo_info "Directory ${REPO} does not exist yet."
    if [ "$INIT" == "y" ]; then
      echo_info "Cloning ${REPO} from GitHub."
      git clone --origin ods ${GITHUB_REPO}
    else
      if [ -z ${BITBUCKET_URL} ]; then
        echo_info "Bitbucket URL is required to set it up."
        read -e -p "Enter your Bitbucket URL, e.g. 'https://bitbucket.example.com': " input
        BITBUCKET_URL=${input:-""}
      fi
      BITBUCKET_REPO="${BITBUCKET_URL}/scm/${OPENDEVSTACK_ORG}/${REPO}.git"
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
        echo_info "Adding remote 'origin' (${BITBUCKET_REPO})."
        git remote add origin ${BITBUCKET_REPO}
        cd -  &> /dev/null
      fi
    fi
  fi

  cd ${REPO}

  # Update remotes
  if ! git remote get-url origin &> /dev/null; then
    if [ "$INIT" == "n" ]; then
      if [ -z ${BITBUCKET_URL} ]; then
        echo_warn "Remote 'origin' is missing.\n"
        read -e -p "Enter your Bitbucket URL, e.g. 'https://bitbucket.example.com': " input
        BITBUCKET_URL=${input:-""}
      fi
      BITBUCKET_REPO="${BITBUCKET_URL}/scm/${OPENDEVSTACK_ORG}/${REPO}.git"
      echo_info "Adding remote 'origin' (${BITBUCKET_REPO})."
      git remote add origin ${BITBUCKET_REPO}
      echo_info "Fetching from remote 'origin'."
      git fetch origin
    fi
  else
    echo_info "Fetching from remote 'origin'."
    git fetch origin
  fi
  if ! git remote get-url ods &> /dev/null; then
    echo_info "Adding remote 'ods' (${GITHUB_REPO})."
    git remote add ods ${GITHUB_REPO}
  fi
  echo_info "Fetching from remote 'ods'."
  git fetch ods

  # Update local ref
  if git rev-parse ${GIT_REF} &> /dev/null; then
    echo_info "Checking out existing local ref '${GIT_REF}'."
    if ! git checkout ${GIT_REF}; then
      echo_error "ods/${GIT_REF} cannot be checked out, which means that your local state has modifications. Please clean your local state."
      exit 1
    fi
    if [ "$SYNC" == "y" ]; then
      echo_info "Merging changes from GitHub (ods/${GIT_REF}) into local ref."
      if ! git merge ods/${GIT_REF}; then
        echo_error "ods/${GIT_REF} cannot be merged, which means the ref on Bitbucket has been modified. Please reset your local ref to ods/${GIT_REF}."
        exit 1
      fi
      if [ "$(git rev-parse ${GIT_REF})" != $(git rev-parse ods/${GIT_REF}) ]; then
        echo_error "${GIT_REF} differs from ods/${GIT_REF}. Please reset your local ref to ods/${GIT_REF}."
        exit 1
      fi
    else
      echo_info "Merging changes from Bitbucket (origin/${GIT_REF}) into local ref."
      if ! git merge origin/${GIT_REF}; then
        echo_error "origin/${GIT_REF} cannot be merged. Please reset your local ref to origin/${GIT_REF}."
        exit 1
      fi
      if [ "$(git rev-parse ${GIT_REF})" != $(git rev-parse origin/${GIT_REF}) ]; then
        echo_error "${GIT_REF} differs from origin/${GIT_REF}. Please reset your local ref to origin/${GIT_REF}."
        exit 1
      fi
    fi
  else
    echo_info "Creating local ref '${GIT_REF}'."
    git checkout -b ${GIT_REF} ods/${GIT_REF} --no-track
    git branch --set-upstream-to origin/${GIT_REF}
  fi
  echo_done "Prepared ${REPO}."

  # Push to Bitbucket
  if [ "$SYNC" == "y" ]; then
    echo_info "Pushing '${GIT_REF}' to Bitbucket."
    git push origin ${GIT_REF}
    echo_done "Pushed '${GIT_REF}' to Bitbucket."
  fi

  cd - &> /dev/null
  echo ""

done
