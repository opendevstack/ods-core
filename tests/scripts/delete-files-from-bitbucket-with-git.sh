#!/usr/bin/env bash
set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
BITBUCKET_USER=""
BITBUCKET_PWD=""
BITBUCKET_PROJECT="unitt"
REPOSITORY=
BRANCH=master
PATHS=()
COMMIT_MESSAGE="Remove files/folders"


function usage {
    printf "Delete files/folders from bitbucket.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\n"
    printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
    printf "\t-u|--user\t\tBitbucket user\n"
    printf "\t-p|--password\t\tBitbucket password\n"
    printf "\t-t|--project\tName of the Bitbucket project (defaults to '%s')\n" "${BITBUCKET_PROJECT}"
    printf "\t-r|--repository\tName of the repository\n"
    printf "\t-f|--files\tFiles/folders to delete (can be specified multiple times)\n"
    printf "\t-m|--message\tCommit message (defaults to 'Remove files/folders')\n"
}


function create_url() {
    url=$1
    user=$2
    password=$3

    # URL encode the @ symbol in the username
    user=$(echo $user | sed 's/@/%40/g')
    password=$(echo $password | sed 's/@/%40/g')

    protocol=$(echo $url | grep :// | sed -e's,^\(.*://\).*,\1,g')
    url=$(echo $url | sed -e s,$protocol,,g)

    echo "${protocol}${user}:${password}@${url}"
}

function configure_user() {
    git config --global user.email "x2odsedpcomm@boehringer-ingelheim.com"
    git config --global user.name "EDPCommunity Automated Test"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -b|--bitbucket) BITBUCKET_URL="$2"; shift;;
    -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;

    -u|--user) BITBUCKET_USER="$2"; shift;;
    -u=*|--user=*) BITBUCKET_USER="${1#*=}";;

    -p|--password) BITBUCKET_PWD="$2"; shift;;
    -p=*|--password=*) BITBUCKET_PWD="${1#*=}";;

    -t|--project) BITBUCKET_PROJECT="$2"; shift;;
    -t=*|--project=*) BITBUCKET_PROJECT="${1#*=}";;

    -r|--repository) REPOSITORY="$2"; shift;;
    -r=*|--repository=*) REPOSITORY="${1#*=}";;

    -f|--files) PATHS+=("$2"); shift;;
    -f=*|--files=*) PATHS+=("${1#*=}");;

    -m|--message) COMMIT_MESSAGE="$2"; shift;;
    -m=*|--message=*) COMMIT_MESSAGE="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

configure_user

url=$(create_url "$BITBUCKET_URL" "$BITBUCKET_USER" "$BITBUCKET_PWD")

# Create a temporary directory and store its name in a variable
TEMP_DIR=$(mktemp -d)

# Clone the repository into the temporary directory
git clone "${url}/scm/${BITBUCKET_PROJECT}/${REPOSITORY}.git" "${TEMP_DIR}"

# Change into the temporary directory
cd "${TEMP_DIR}"

# Switch to the desired branch
git checkout "${BRANCH}"

# Delete the files/folders
deleted_count=0
for path in "${PATHS[@]}"; do
    if [ -e "$path" ]; then
        git rm -rf "$path"
        deleted_count=$((deleted_count + 1))
        echo_info "Deleted: $path"
    else
        echo_warn "Path not found, skipping: $path"
    fi
done

if [ $deleted_count -eq 0 ]; then
    echo_info "No files/folders found to delete"
    cd -
    rm -rf "${TEMP_DIR}"
    exit 0
fi

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo_info "No changes to commit, all files already deleted or not found"
else
    # Commit the changes
    git commit -m "${COMMIT_MESSAGE}"

    # Push the changes
    git push origin "${BRANCH}"
fi

# Change back to the original directory
cd -

# Remove the temporary directory
rm -rf "${TEMP_DIR}"

echo_done "Deleted $deleted_count file(s)/folder(s) from ${BITBUCKET_PROJECT}/${REPOSITORY}"
