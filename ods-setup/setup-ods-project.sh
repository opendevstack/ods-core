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

# Create namespace
if oc project ${NAMESPACE}; then
  echo "The project '${NAMESPACE}' already exists"
else
  echo "Creating project '${NAMESPACE}' ..."
  oc new-project ${NAMESPACE} --description="Central ODS namespace with shared resources" --display-name="OpenDevStack"
fi

# Allow system:authenticated group to view resources in central namespace
oc adm policy add-role-to-group view system:authenticated -n ${NAMESPACE}

# Allow system:authenticated group to pull images from central namespace
if ! oc adm policy add-cluster-role-to-group system:image-puller system:authenticated -n ${NAMESPACE}; then
  echo "You might not have enough rights to assign 'system:image-puller' to 'system:authenticated'."
  echo "This script needs to be run by a cluster admin."
  exit 1
fi

# Allow Jenkins serviceaccount to create new projects
if ! oc adm policy add-cluster-role-to-user self-provisioner system:serviceaccount:${NAMESPACE}:jenkins; then
  echo "You might not have enough rights to assign 'self-provisioner' to 'system:serviceaccount:${NAMESPACE}:jenkins'."
  echo "This script needs to be run by a cluster admin."
  exit 1
fi

# Create a new role 'edit-atlassian-team' without secret-related resources access
if ! oc get clusterrole edit-atlassian-team > /dev/null 2>&1; then
  echo "You might not have enough rights to create the new role 'edit-atlassian-team'."
  echo "This script needs to be run by a cluster admin."
  
  # Create a temporary file
  TEMP_FILE=$(mktemp 2>/dev/null || echo "/tmp/tempfile_$$")
  
  # Get the edit role YAML and rename it
  oc get clusterrole edit -o yaml | sed 's/name: edit/name: edit-atlassian-team/' > $TEMP_FILE
  
  # Process the YAML to remove secret-related resources, empty sections, and metadata fields
  PROCESSED_FILE=$(mktemp 2>/dev/null || echo "/tmp/tempfile_$$")
  
  awk '
  BEGIN { 
    skip_current_group = 0; 
    inside_api_group = 0;
    api_group_buffer = "";
    skip_section = 0;
    in_metadata = 0;
    contains_secret = 0;
  }
  
  # Skip metadata fields and sections
  /creationTimestamp:/ || /resourceVersion:/ || /uid:/ {
    next;
  }
  
  # Detect start of aggregationRule section and skip it
  /^aggregationRule:/ {
    skip_section = 1;
    next;
  }
  
  # Detect end of aggregationRule section (when we see apiVersion)
  /^apiVersion:/ {
    skip_section = 0;
    print $0;
    next;
  }
  
  # Track if we are in metadata section
  /^metadata:/ {
    in_metadata = 1;
    print $0;
    next;
  }
  
  # Detect start of annotations or labels in metadata and skip them
  /^  annotations:/ || /^  labels:/ {
    if (in_metadata) {
      skip_section = 1;
      next;
    }
  }
  
  # Detect when we leave annotations or labels section (any line with single indent level)
  /^  [a-zA-Z]/ {
    if (skip_section && in_metadata && $0 !~ /^  annotations:/ && $0 !~ /^  labels:/) {
      skip_section = 0;
    }
  }
  
  # Detect end of metadata section
  /^[a-zA-Z]/ && in_metadata && $0 !~ /^metadata:/ {
    in_metadata = 0;
  }
  
  # Skip lines while in a section we want to skip
  {
    if (skip_section) {
      next;
    }
  }
  
  # Detect API Groups line
  /^- apiGroups:/ {
    # If we were previously in an API group, print it if it wasnt being skipped and has no secrets
    if (inside_api_group && !skip_current_group && !contains_secret && api_group_buffer != "") {
      print api_group_buffer;
    }
    
    # Reset variables for new group
    inside_api_group = 1;
    api_group_buffer = $0;
    skip_current_group = 0;
    contains_secret = 0;
    
    # Check if this apiGroup itself contains "secret"
    if ($0 ~ /secret/ || $0 ~ /external-secrets\.io/) {
      skip_current_group = 1;
    }
    next;
  }
  
  # Look for resources section that might contain secrets
  /^  resources:/ {
    api_group_buffer = api_group_buffer "\n" $0;
    next;
  }
  
  # Check for secret in resource names
  /^  - / && inside_api_group {
    # If this resource contains "secret", mark the group for skipping
    if ($0 ~ /secret/) {
      contains_secret = 1;
    }
    api_group_buffer = api_group_buffer "\n" $0;
    next;
  }
  
  # Process all other lines
  {
    if (inside_api_group) {
      # Add to buffer
      api_group_buffer = api_group_buffer "\n" $0;
    } else {
      # Not in an API group, print directly
      print $0;
    }
  }
  
  END {
    # Print the last API group if it wasnt being skipped and has no secrets
    if (inside_api_group && !skip_current_group && !contains_secret && api_group_buffer != "") {
      print api_group_buffer;
    }
  }' $TEMP_FILE > $PROCESSED_FILE
  
  # Create the role and clean up
  oc create -f $PROCESSED_FILE
  rm $TEMP_FILE $PROCESSED_FILE
fi

# Create cd-user secret
cd ${SCRIPT_DIR}/ocp-config/cd-user
${TAILOR} -n ${NAMESPACE} apply ${NON_INTERACTIVE} ${REVEAL_SECRETS}
cd -

echo "Done"
