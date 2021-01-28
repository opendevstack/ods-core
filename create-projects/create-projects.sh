#!/usr/bin/env bash
set -e

# As this script is executed within the context of Jenkins, which has some
# env vars exposed (via the DeploymentConfig, but also from inside the image).
# It might be surprising to have them alter what the script does without seeing
# them passed/set in the Jenkinsfile. That's why we reset all env vars here
# and require them to be passed as parameters to the script.

PROJECT_ID=""
PROJECT_ADMINS=""
PROJECT_GROUPS=""
# Role 'admin' is needed to clone an entire project including role bindings
# for env autoclonding in the Jenkins shared library.
JENKINS_ROLE="admin"

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-p|--project\tProject ID\n"
  printf "\t--admins\tAdmins of the projects\n"
  printf "\t--groups\tGroups with permissions (e.g. 'USERGROUP=foo,ADMINGROUP=bar,READONLYGROUP=baz')\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -p=*|--project=*) PROJECT_ID="${1#*=}";;
  -p|--project)     PROJECT_ID="$2"; shift;;

  --admins=*) PROJECT_ADMINS="${1#*=}";;
  --admins)   PROJECT_ADMINS="$2"; shift;;

  --groups=*) PROJECT_GROUPS="${1#*=}";;
  --groups)   PROJECT_GROUPS="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

# check required parameters
if [ -z "${PROJECT_ID}" ]; then
  echo "PROJECT_ID is unset"; usage
  exit 1
else
	echo "PROJECT_ID=${PROJECT_ID}"
fi

echo "Create projects ${PROJECT_ID}-cd, ${PROJECT_ID}-dev and ${PROJECT_ID}-test"
oc new-project "${PROJECT_ID}-cd"
oc new-project "${PROJECT_ID}-dev"
oc new-project "${PROJECT_ID}-test"

echo "Allow serviceaccount 'jenkins' of ${PROJECT_ID}-cd to admin the environment projects"
oc policy add-role-to-user "${JENKINS_ROLE}" "system:serviceaccount:${PROJECT_ID}-cd:jenkins" -n "${PROJECT_ID}-dev"
oc policy add-role-to-user "${JENKINS_ROLE}" "system:serviceaccount:${PROJECT_ID}-cd:jenkins" -n "${PROJECT_ID}-test"

echo "Grant serviceaccount 'jenkins' role 'edit' in ${PROJECT_ID}-cd"
oc policy add-role-to-user edit --serviceaccount jenkins -n "${PROJECT_ID}-cd"

echo "Allow to pull ${PROJECT_ID}-dev images from ${PROJECT_ID}-test"
oc policy add-role-to-group system:image-puller "system:serviceaccounts:${PROJECT_ID}-test" -n "${PROJECT_ID}-dev"

echo "Allow ${PROJECT_ID}-dev and ${PROJECT_ID}-test to pull ${PROJECT_ID}-cd images"
oc policy add-role-to-group system:image-puller "system:serviceaccounts:${PROJECT_ID}-test" -n "${PROJECT_ID}-cd"
oc policy add-role-to-group system:image-puller "system:serviceaccounts:${PROJECT_ID}-dev" -n "${PROJECT_ID}-cd"

echo "Grant serviceaccount 'default' role 'image-builder' to import images from other cluster"
oc policy add-role-to-user system:image-builder --serviceaccount default -n "${PROJECT_ID}-dev"
oc policy add-role-to-user system:image-builder --serviceaccount default -n "${PROJECT_ID}-test"

if [ -n "${PROJECT_ADMINS}" ]; then
  # By default only role 'dedicated-admin' has admin rights
  echo "Seeding admins (${PROJECT_ADMINS}) ..."
  for admin_user in ${PROJECT_ADMINS//,/ }; do
    echo "- seeding admin: ${admin_user}"
    oc policy add-role-to-user admin "${admin_user}" -n "${PROJECT_ID}-dev"
    oc policy add-role-to-user admin "${admin_user}" -n "${PROJECT_ID}-test"
    oc policy add-role-to-user admin "${admin_user}" -n "${PROJECT_ID}-cd"
  done
  
  echo "Assign the owner as a label to the OpenShift project"
  # Take the first in the list as owner of the project.
  # Labels do not allow the '@' char so let's replace it with '_at_'
  # For instance, foo@bar.com will be converted to foo_at_bar.com
  # resulting in the following label: ods.project.owner=foot_at_bar.com
  namespace_owner=$(echo "${PROJECT_ADMINS}" | cut -d "," -f1 | sed -r 's/@/_at_/g')

  oc label namespace "${PROJECT_ID}-dev" ods.project.owner="${namespace_owner}"
  oc label namespace "${PROJECT_ID}-test" ods.project.owner="${namespace_owner}"
  oc label namespace "${PROJECT_ID}-cd" ods.project.owner="${namespace_owner}"
fi

if [ -n "${PROJECT_GROUPS}" ]; then
  echo "Seeding special permission groups (${PROJECT_GROUPS}) ..."
  for group in ${PROJECT_GROUPS//,/ }; do
    groupName=$(echo "${group}" | cut -d "=" -f1)
    groupValue=$(echo "${group}" | cut -d "=" -f2)

    usergroup_role="edit"
    admingroup_role="admin"
    readonlygroup_role="view"

    if [ "${groupValue}" == "" ]; then
      continue
    fi

    echo "- seeding group: ${groupName} - ${groupValue}"
    shopt -s nocasematch
    if [[ "${groupName}" == *USERGROUP* ]]; then
      oc policy add-role-to-group "${usergroup_role}" "${groupValue}" -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group "${usergroup_role}" "${groupValue}" -n "${PROJECT_ID}-test"
      oc policy add-role-to-group "${usergroup_role}" "${groupValue}" -n "${PROJECT_ID}-cd"
    elif [[ "${groupName}" == *ADMINGROUP* ]]; then
      oc policy add-role-to-group "${admingroup_role}" "${groupValue}" -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group "${admingroup_role}" "${groupValue}" -n "${PROJECT_ID}-test"
      oc policy add-role-to-group "${admingroup_role}" "${groupValue}" -n "${PROJECT_ID}-cd"
    elif [[ "${groupName}" == *READONLYGROUP* ]]; then
      oc policy add-role-to-group "${readonlygroup_role}" "${groupValue}" -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group "${readonlygroup_role}" "${groupValue}" -n "${PROJECT_ID}-test"
      oc policy add-role-to-group "${readonlygroup_role}" "${groupValue}" -n "${PROJECT_ID}-cd"
    fi
  done
else
  echo "Allow all authenticated users to view the project"
  oc policy add-role-to-group view system:authenticated -n "${PROJECT_ID}-dev"
  oc policy add-role-to-group view system:authenticated -n "${PROJECT_ID}-test"
  oc policy add-role-to-group view system:authenticated -n "${PROJECT_ID}-cd"

  echo "Allow all authenticated users to edit the project"
  oc policy add-role-to-group edit system:authenticated -n "${PROJECT_ID}-dev"
  oc policy add-role-to-group edit system:authenticated -n "${PROJECT_ID}-test"
  oc policy add-role-to-group edit system:authenticated -n "${PROJECT_ID}-cd"
fi
