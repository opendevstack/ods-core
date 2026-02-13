#!/bin/bash
##set -ue
#set -o pipefail

me=${0##*/}

QUICKSTARTERS_REPOSITORY_URL=""
OPENSHIFT_TOKEN=""
ODS_REF="master"
JENKINS_URL=""
PROJECT=""
BRANCHES=""
JENKINS_FOLDER_NAME="qs-automated-tests"
SCRIPT_PATH=$(pwd)
JOB_TEMPLATE="$SCRIPT_PATH/job_template.xml"
RUN_ALL_TEMPLATE="$SCRIPT_PATH/run_all.xml"
TMP_FOLDER=$SCRIPT_PATH/tmp
REPOSITORY_NAME=""
REPOSITORY_USERNAME=""
REPOSITORY_PASSWORD=""
NO_CLONE=

echo_done(){
    echo -e "[DONE]: $@"
}

echo_warn(){
    echo -e "[WARN]: $@"
}

echo_error(){
    echo -e "[ERROR]: $@"
}

echo_info(){
    echo -e "[INFO]: $@"
}

function environment() {
    echo_info "Environment:"
    echo_info "  SCRIPT_PATH:                   $SCRIPT_PATH"
    echo_info "  JOB_TEMPLATE:                  $JOB_TEMPLATE"
    echo_info "  RUN_ALL_TEMPLATE:              $RUN_ALL_TEMPLATE"
    echo_info "  TMP_FOLDER:                    $TMP_FOLDER"
    echo_info "  PROJECT:                       $PROJECT"
    echo_info "  QUICKSTARTERS_REPOSITORY_URL:  $QUICKSTARTERS_REPOSITORY_URL"
    echo_info "  BRANCHES:                      ${BRANCHES:-all}"
    echo_info "  JENKINS_FOLDER_NAME:           $JENKINS_FOLDER_NAME"
}

function prerrequisites() {
    local error=0

    echo_info "Verifying parameters"

    if [ -z "${OPENSHIFT_TOKEN}" ]; then
        OPENSHIFT_TOKEN=$(oc whoami -t)
        if [ -z "${OPENSHIFT_TOKEN}" ]; then
            echo_warn "--openshift-token is mandatory or you must be logged in a cluster."
            error=1
        fi
    fi

    if [ -z "${QUICKSTARTERS_REPOSITORY_URL}" ]; then
        echo_warn "--quickstarters-repository is mandatory"
        error=1
    fi

    if [ -z "${JENKINS_URL}" ]; then
        echo_warn "--jenkins-url is mandatory"
        error=1
    fi

    if [ -z "${PROJECT}" ]; then
        echo_warn "--project is mandatory"
        error=1
    fi

    if [[ error -ne 0 ]]; then
        usage
        exit 1
    fi

    rm -Rf tmp
    mkdir -p tmp

    # Extract the repository name
    REPOSITORY_NAME=$(basename $QUICKSTARTERS_REPOSITORY_URL .git)
}

function process_repo_qs_branch() {
    # Create parent folder first
    create_jenkins_folder "$JENKINS_FOLDER_NAME"
    
    if [ -z "${NO_CLONE}" ]; then
        echo_info "Clone the Quickstarter Repository: $QUICKSTARTERS_REPOSITORY_URL"        
        rm -rf repo        
        git clone $QUICKSTARTERS_REPOSITORY_URL repo --quiet
        [ $? -ne 0 ] && exit 1
    fi

    
    ## Change to the repo directory
    pushd repo

    # Get all branches
    for branch in $(git branch -r | grep -v HEAD);do
        local filtered_branch=$(echo $branch| sed 's/origin\///')
        
        # Skip branch if BRANCHES is specified and this branch is not in the list
        if [ -n "$BRANCHES" ]; then
            if ! echo "$BRANCHES" | grep -qw "$filtered_branch"; then
                echo_info "Skipping branch: $filtered_branch (not in specified branches list)"
                continue
            fi
        fi
        
        git checkout $filtered_branch --quiet
        
        create_jenkins_folder "$JENKINS_FOLDER_NAME/$filtered_branch"        

        # Get directories in the root
        for dir in $(ls -d */);do
            # Check if directory contains a folder named 'testdata'
            if [ -d "$dir/testdata" ]; then
                create_job branch=$filtered_branch ods_ref=$ODS_REF template=$JOB_TEMPLATE  qs=${dir//\//}
            fi
        done

        # Create the run_all orchestration job for this branch
        echo_info "Creating run_all orchestration job for branch: ${filtered_branch}"
        create_run_all_job branch=$filtered_branch
    done
    popd
}

function replace_placeholders {
  # Get the input and output files from the arguments
  local INPUT_FILE=$1
  local OUTPUT_FILE=$2
  shift 2
  
  echo_info "Creating file $OUTPUT_FILE from $INPUT_FILE"
  # Create a copy of the input file to the output file
  cp $INPUT_FILE $OUTPUT_FILE

  # Loop over the remaining arguments
  for ARG in "$@"; do
    # Use the IFS variable to split the argument into a placeholder and a value
    IFS='=' read -r PLACEHOLDER REPLACEMENT_VALUE <<< "$ARG"

    # Use the sed command to replace the placeholder with the replacement value
    sed -i "s|${PLACEHOLDER}|${REPLACEMENT_VALUE}|g" $OUTPUT_FILE
  done
}

# This bash function creates or updates a Jenkins job.
# It first checks if the job already exists, and if it does, it updates it.
# If it doesn't, it creates a new one.
# The job configuration is based on a template file, where placeholders are replaced with actual values.
#
# Arguments:
#   $1 - The branch name
#   $2 - The quickstarter name
#   $3 - The OpenDevStack reference
#
# Globals:
#   JOB_TEMPLATE - The path to the job configuration template file
#   TMP_FOLDER - The path to the temporary folder where the job configuration file is stored
#   PROJECT - The project name
#   QUICKSTARTERS_REPOSITORY_URL - The URL of the quickstarters repository
#   REPOSITORY_NAME - The name of the repository
#   JENKINS_URL - The URL of the Jenkins server
#   OPENSHIFT_TOKEN - The OpenShift token used for authentication
#
# Returns:
#   None
function create_job() {
    local branch=""
    local qs=""
    local ods_ref=""
    local template=""
    local job_name=""
    local data_binary=""
    local folder=""

    for arg in "$@"
    do
        IFS='=' read -r key value <<< "$arg"
        case "$key" in
        branch) branch="$value" ;;
        qs) qs="$value" ;;
        ods_ref) ods_ref="$value" ;;
        template) template="$value" ;;
        job_name) job_name="$value" ;;
        esac
    done

    echo_info "branch: ${branch}, ods_ref: ${ods_ref}, template: ${template}, qs: ${qs}, job_name: ${job_name}"

    local job_filename=${job_name:-"$branch-$qs-$ods_ref"}.xml

    if [ -z "$branch" ] || [ -z "$ods_ref" ] || [ -z "$template" ]; then
        echo_error "(create_job): Missing mandatory parameters."
        return 1
    fi

    replace_placeholders "$template" "$TMP_FOLDER/$job_filename" \
        "{{PROJECT}}=$PROJECT" \
        "{{QUICKSTARTERS_REPOSITORY_URL}}=$QUICKSTARTERS_REPOSITORY_URL" \
        "{{QS}}=$REPOSITORY_NAME/$qs" \
        "{{BRANCH}}=$branch" \
        "{{ODSREF}}=$ods_ref" \
        "{{BITBUCKET_URL}}=${BITBUCKET_URL}" \
        "{{CREDENTIALS_ID}}=${CREDENTIALS_ID}" \
        "{{OPENSHIFT_APPS_BASEDOMAIN}}=${OPENSHIFT_APPS_BASEDOMAIN}"\
        "{{ODS_QUICKSTARTERS_TESTS_BRANCH}}=${ODS_QUICKSTARTERS_TESTS_BRANCH}"

    echo_info "branch: $branch, qs: $qs, job_name: $job_name, folder: /job/$JENKINS_FOLDER_NAME/job/$branch"
    local exists=1
    if [ -n "$job_name" ]; then
        # For ALL-branch jobs, create directly under the branch folder
        folder="/job/$JENKINS_FOLDER_NAME/job/$branch"
        echo_info "Checking existence for: /$JENKINS_FOLDER_NAME/$branch/$job_name"
        check_jenkins_resource_exists "/$JENKINS_FOLDER_NAME/$branch/$job_name"
        exists=$?
    else
        # For regular QS jobs, create under the branch folder
        folder="/job/$JENKINS_FOLDER_NAME/job/$branch"
        echo_info "Checking existence for: /$JENKINS_FOLDER_NAME/$branch/$qs"
        check_jenkins_resource_exists "/$JENKINS_FOLDER_NAME/$branch/$qs"
        exists=$?
    fi
    local url="$JENKINS_URL$folder"
    echo_info "Job existence check exit code: $exists"
    if [[ $exists -eq 0 ]]; then
        if [ -n "$job_name" ]; then
            echo_info "Job '$JENKINS_FOLDER_NAME/$branch/$job_name' - ods-ref($ods_ref) already exists. If you want to recreate it, delete all resources related with it."
        else
            echo_info "Job '$JENKINS_FOLDER_NAME/$branch/$qs' - ods-ref($ods_ref) already exists. If you want to recreate it, delete all resources related with it."
        fi
        return 0
    fi
    if [ -n "$job_name" ]; then
        echo_info "Creating job '$JENKINS_FOLDER_NAME/$branch/$job_name' - ods-ref($ods_ref)"
    else
        echo_info "Creating job '$JENKINS_FOLDER_NAME/$branch/$qs' - ods-ref($ods_ref)"
    fi
    url+="/createItem?name=${job_name:-"$qs"}"

    curl -s $INSECURE -XPOST "$url" --data-binary @$TMP_FOLDER/$job_filename --header "Authorization: Bearer ${OPENSHIFT_TOKEN}" --header "Content-Type:text/xml"
    [ $? -ne 0 ] && echo_warn "Error creating $job_name"
}

# This function creates a run_all orchestration job for a branch.
# The job configuration is taken directly from run_all.xml without any placeholder substitution.
#
# Arguments:
#   branch - The branch name
#
# Globals:
#   RUN_ALL_TEMPLATE - The path to the run_all.xml template file
#   TMP_FOLDER - The path to the temporary folder where the job configuration file is stored
#   JENKINS_URL - The URL of the Jenkins server
#   JENKINS_FOLDER_NAME - The Jenkins folder name
#   OPENSHIFT_TOKEN - The OpenShift token used for authentication
#
# Returns:
#   None
function create_run_all_job() {
    local branch=""

    for arg in "$@"
    do
        IFS='=' read -r key value <<< "$arg"
        case "$key" in
        branch) branch="$value" ;;
        esac
    done

    if [ -z "$branch" ]; then
        echo_error "(create_run_all_job): Missing mandatory branch parameter."
        return 1
    fi

    local job_name="RUN-ALL"
    local job_filename="${branch}-${job_name}.xml"

    echo_info "Creating run_all job for branch: $branch"

    # Copy the run_all.xml template without any substitution
    cp "$RUN_ALL_TEMPLATE" "$TMP_FOLDER/$job_filename"

    # Check if the job already exists
    local folder="/job/$JENKINS_FOLDER_NAME/job/$branch"
    echo_info "Checking existence for: /$JENKINS_FOLDER_NAME/$branch/$job_name"
    check_jenkins_resource_exists "/$JENKINS_FOLDER_NAME/$branch/$job_name"
    local exists=$?

    if [[ $exists -eq 0 ]]; then
        echo_info "Job '$JENKINS_FOLDER_NAME/$branch/$job_name' already exists. If you want to recreate it, delete all resources related with it."
        return 0
    fi

    echo_info "Creating job '$JENKINS_FOLDER_NAME/$branch/$job_name'"
    local url="$JENKINS_URL$folder/createItem?name=${job_name}"

    curl -s $INSECURE -XPOST "$url" --data-binary @$TMP_FOLDER/$job_filename --header "Authorization: Bearer ${OPENSHIFT_TOKEN}" --header "Content-Type:text/xml"
    [ $? -ne 0 ] && echo_warn "Error creating $job_name"
}

function check_jenkins_resource_exists() {
    local resource_name=$1
    local jenkins_resource_name=$(echo ${resource_name} | sed 's/\//\/job\//g')
    
    echo_info "Checking if Job or Folder [${jenkins_resource_name}] exists..."
        
    local response=$(curl $INSECURE -s -o /dev/null -w "%{http_code}"  -I -XGET "$JENKINS_URL${jenkins_resource_name}/config.xml" --header "Authorization: Bearer ${OPENSHIFT_TOKEN}")
    if [[ "$response" -eq 200 ]]; then
        echo_warn "Folder or Job [${resource_name}] exists"
        return 0
    fi
    echo_info "Folder or Job [${resource_name}] does not exist"
    
    return 1
}

function create_jenkins_folder() {
    local folder_name=$1

    check_jenkins_resource_exists /$folder_name
    
    if [[ $? -ne 0 ]]; then
        echo_info "Creating folder: $folder_name"
        
        # Extract parent folder and folder name for nested folders
        local parent_path=""
        local folder_basename="${folder_name}"
        
        if [[ "$folder_name" == */* ]]; then
            parent_path="${folder_name%/*}"
            folder_basename="${folder_name##*/}"
            # Convert parent path to Jenkins job URL format
            parent_path="/job/${parent_path//\//\/job\/}"
        fi
        
        curl -s $INSECURE -XPOST "${JENKINS_URL}${parent_path}/createItem?name=${folder_basename}&mode=com.cloudbees.hudson.plugins.folder.Folder&from=&json=%7B%22name%22%3A%22${folder_basename}%22%2C%22mode%22%3A%22com.cloudbees.hudson.plugins.folder.Folder%22%2C%22from%22%3A%22%22%2C%22Submit%22%3A%22OK%22%7D&Submit=OK" --header "Authorization: Bearer ${OPENSHIFT_TOKEN}" --header "Content-Type:application/x-www-form-urlencoded"
    fi
}

function usage {
    printf "\n"
    printf "This script creates Jenkins folders and Jobs for the existing Quickstarters in the provided repository.\n\n"
    printf "Syntax ./${me} parameters.\n\n"

    printf "MANDATORY\n"
    printf "\t-q|--quickstarters-repository\tBitbucket URL, e.g. 'https://github.com/opendevstack/ods-quickstarters.git'.\n"
    printf "\t-t|--openshift-token\t\tOpenshift token.\n"
    printf "\t-p|--project\t\t\tProject Key.\n"

    printf "OPTIONAL\n"
    printf "\t-j|--jenkins-url\t\tJenkins url (only if you are not logged in the cluster or you don't have 'oc' installed).\n"
    printf "\t-b|--branches\t\t\tSpace-separated list of branches to process (e.g., 'master 4.x 5.x'). If not specified, all branches will be processed.\n"
    printf "\t-f|--folder-name\t\tJenkins folder name (defaults to 'qs-automated-tests').\n"
    printf "\t-h|--help\t\t\tPrint usage.\n"
    printf "\t-v|--verbose\t\t\tEnable verbose mode.\n"
    printf "\t-i|--insecure\t\t\tAllow insecure server connections when using SSL.\n"
    printf "\t-i|--no-clone\t\t\tDo not clone if it is already cloned.\n"
    printf "\n"
    printf "\t-o|--ods-ref\t\t\tODS Reference, e.g. 'master, 4.x' (defaults to $ODS_REF)\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -i|--insecure) INSECURE="--insecure";;

    -p|--project) PROJECT="$2"; shift;;
    -p=*|--project=*) PROJECT="${1#*=}";;

    -b|--branches) BRANCHES="$2"; shift;;
    -b=*|--branches=*) BRANCHES="${1#*=}";;

    -f|--folder-name) JENKINS_FOLDER_NAME="$2"; shift;;
    -f=*|--folder-name=*) JENKINS_FOLDER_NAME="${1#*=}";;

    -q|--quickstarters-repository) QUICKSTARTERS_REPOSITORY_URL="$2"; shift;;
    -q=*|--quickstarters-repository=*) QUICKSTARTERS_REPOSITORY_URL="${1#*=}";;

    -o|--ods-ref) ODS_REF="$2"; shift;;
    -o=*|--ods-ref=*) ODS_REF="${1#*=}";;

    -j|--jenkins-url) JENKINS_URL="$2"; shift;;
    -j=*|--jenkins-url=*) JENKINS_URL="${1#*=}";;

    -t|--openshift-token) OPENSHIFT_TOKEN="$2"; shift;;
    -t=*|--openshift-token=*) OPENSHIFT_TOKEN="${1#*=}";;

    -u|--user-name) REPOSITORY_USERNAME="$2"; shift;;
    -u=*|--user-name=*) REPOSITORY_USERNAME="${1#*=}";;

    -pw|--user-password) REPOSITORY_PASSWORD="$2"; shift;;
    -pw=*|--user-password=*) REPOSITORY_PASSWORD="${1#*=}";;

    -bb|--bitbucket-url) BITBUCKET_URL="$2"; shift;;
    -bb=*|--bitbucket-url=*) BITBUCKET_URL="${1#*=;;}";;

    -credential-id|--credentials-id) CREDENTIALS_ID="$2"; shift;;
    -credential-id=*|--credentials-id=*) CREDENTIALS_ID="${1#*=}";;

    -oqtb|--ods-quickstarters-test-branch) ODS_QUICKSTARTERS_TESTS_BRANCH="$2"; shift;;
    -oqtb=*|--ods-quickstarters-test-branch=*) ODS_QUICKSTARTERS_TESTS_BRANCH="${1#*=}";;


    --no-clone) NO_CLONE=true;;




  *) echo_error "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

environment
prerrequisites
process_repo_qs_branch 
[ $? -eq 0 ] && echo_done "Jobs created"
