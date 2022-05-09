#!/usr/bin/env bash
# repos.sh is supposed to be downloaded and used from the umbrella directory
# holding the OpenDevStack repositories. It will ensure all required
# repositories are present on the local machine, and checked out at the
# specified Git ref. The Git ref has to exist in the specified source project.
# The source project defaults to the "opendevstack" organisation in GitHub, but
# it is also possible to use this script to just fetch what is present in
# Bitbucket (e.g. for admins wanting to work against an existing, possibly
# customized installation of OpenDevStack without updating / changing it).

set -ue

WORKING_DIR=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [[ "$SCRIPT_DIR" == *ods-core/scripts ]]; then
    echo "This script must not be used from within ods-core."
    echo "It is supposed to be downloaded to the umbrella directory holding all ODS respositories."
    echo "The following example shows how to do this for the 'master' version:"
    echo ""
    echo "  UMBRELLA_DIR=~/opendevstack"
    echo "  GIT_REF=master"
    echo "  mkdir -p \$UMBRELLA_DIR && cd \$UMBRELLA_DIR"
    echo "  curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/\$GIT_REF/scripts/repos.sh"
    echo "  chmod +x repos.sh"
    echo "  ./repos.sh --git-ref \$GIT_REF"
    echo ""
    exit 1
fi

# Since this script might be used for bootstrapping, we cannot use
# colored_output.sh here.
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

DEFAULT_SOURCE_PROJECT="https://github.com/opendevstack"
REMOTE_NAME=""
SOURCE_PROJECT=""
GIT_REF=""
REPOS="ods-core, ods-quickstarters, ods-jenkins-shared-library, ods-document-generation-templates"

function usage {
    printf "Initialise and/or update local OpenDevStack repositories.\n\n"
    printf "Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n\n"
    printf "\t-s|--source-project\tSource project (defaults to '%s')\n\t\t\t\tYou may also use an existing Bitbucket project if you only want to mirror\n\t\t\t\tthe current state locally, e.g. https://bitbucket.acme.org/scm/opendevstack\n\t\t\t\tIf the flag is set, its value is assumed to be the 'origin' remote.\n\n" "${DEFAULT_SOURCE_PROJECT}"
    printf "\t-r|--repos\t\tRepositories to handle (comma-separated)\n\t\t\t\tDefaults to: %s\n\n" "${REPOS}"
    printf "\t-g|--git-ref\t\tGit ref, e.g. 'v4.0.0' or 'master'\n\n"
    printf "NOTE: Before you run this script, make sure to have at least Git 2.13 in your system.\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -s|--source-project) SOURCE_PROJECT="$2"; shift;;
    -s=*|--source-project=*) SOURCE_PROJECT="${1#*=}";;

    -g|--git-ref) GIT_REF="$2"; shift;;
    -g=*|--git-ref=*) GIT_REF="${1#*=}";;

    -r|--repos) REPOS="$2"; shift;;
    -r=*|--repos=*) REPOS="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# Handle Git ref parameter.
if [ -z "${GIT_REF}" ]; then
    echo_error "Git ref must not be empty."
    exit 1
fi

# Handle source project parameter.
# By default we use "ods" as remote name. If --source-project is passed,
# we asume it is the "origin" remote.
if [ -z "${SOURCE_PROJECT}" ]; then
    REMOTE_NAME="ods"
    SOURCE_PROJECT="${DEFAULT_SOURCE_PROJECT}"
else
    REMOTE_NAME="origin"
fi

echo_info "Umbrella directory is ${WORKING_DIR}."
echo_info "Repositories: ${REPOS}"
echo_info "Each repository will be checked out @ ${REMOTE_NAME}/${GIT_REF}."
echo ""

# Initialise and update respositories.
for REPO in ${REPOS//,/ }; do
    echo_info "Preparing ${REPO}."
    REPO_URL="${SOURCE_PROJECT}/${REPO}.git"

    # Ensure Git repository is cloned
    if [ -d "${REPO}" ] ; then
        echo_info "Directory ${REPO} exists already."
    else
        echo_info "Directory ${REPO} does not exist yet."
        echo_info "Cloning ${REPO} from ${REPO_URL}."
        git clone --origin "${REMOTE_NAME}" "${REPO_URL}"
    fi

    cd "${REPO}"

    # Fetch from remote
    if ! git remote get-url "${REMOTE_NAME}" &> /dev/null; then
        echo_info "Adding remote '${REMOTE_NAME}' (${REPO_URL})."
        git remote add "${REMOTE_NAME}" "${REPO_URL}"
    fi
    echo_info "Fetching from remote '${REMOTE_NAME}'."
    git fetch "${REMOTE_NAME}"

    if [ "${REPO}" != "ods-document-generation-templates" ]; then

        CHECKOUT_REF="${GIT_REF}"
        # ods-configuration is not part of the repos by default, but there
        # are use cases in which someone might add it. If it is added, we
        # need to checkout master as the config repo does not follow ODS
        # versioning. Only the master branch is maintained.
        if [ "${REPO}" == "ods-configuration" ]; then
            CHECKOUT_REF="master"
        fi

        # Update local ref.
        # The following succeeds for "new" tags as they are found by rev-parse once
        # they have been fetched from the remote.
        if git rev-parse "${CHECKOUT_REF}" &> /dev/null; then
            echo_info "Checking out existing local ref '${CHECKOUT_REF}'."
            if ! git checkout "${CHECKOUT_REF}" &> /dev/null; then
                echo_error "${CHECKOUT_REF} cannot be checked out, which means that your local state has modifications. Please clean your local state."
                exit 1
            fi
            if ! git show-ref --verify --quiet "refs/tags/${CHECKOUT_REF}"; then
                echo_info "Merging changes from remote (${REMOTE_NAME}/${CHECKOUT_REF}) into local branch."
                if ! git merge "${REMOTE_NAME}/${CHECKOUT_REF}" &> /dev/null; then
                    echo_error "${REMOTE_NAME}/${CHECKOUT_REF} cannot be merged. Please reset your local branch to ${REMOTE_NAME}/${CHECKOUT_REF}."
                    exit 1
                fi
                if [ "$(git rev-parse "${CHECKOUT_REF}")" != "$(git rev-parse "${REMOTE_NAME}/${CHECKOUT_REF}")" ]; then
                    echo_error "${CHECKOUT_REF} differs from ${REMOTE_NAME}/${CHECKOUT_REF}. Please reset your local branch to ${REMOTE_NAME}/${CHECKOUT_REF}."
                    exit 1
                fi
            fi
        else
            echo_info "Creating new branch based on '${REMOTE_NAME}/${CHECKOUT_REF}': show remotes && fetch all && check branch exists && checkout"
            git remote -v
            git fetch --all
            git branch -a | grep -i "${CHECKOUT_REF}"
            git checkout -b "${CHECKOUT_REF}" "${REMOTE_NAME}/${CHECKOUT_REF}" --no-track
        fi
    fi

    echo_done "Prepared ${REPO}."

    cd - &> /dev/null
    echo ""

done

echo_done "Prepared all local repositories @ ${GIT_REF}."
