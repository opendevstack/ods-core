#!/usr/bin/env bash
set -e

PROJECT_ID=""
PROJECT_ADMIN=""
PROJECT_GROUPS=""
# Role 'admin' is needed to clone an entire project including role bindings
# for env autoclonding in the Jenkins shared library.
JENKINS_ROLE="admin"

function usage {
  printf "usage: %s [options]\n" $0
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

  --admin=*) PROJECT_ADMIN="${1#*=}";;
  --admin)   PROJECT_ADMIN="$2"; shift;;

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
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT_ID}-cd:jenkins -n "${PROJECT_ID}-dev"
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT_ID}-cd:jenkins -n "${PROJECT_ID}-test"

echo "Grant serviceaccount 'jenkins' role 'edit' in ${PROJECT_ID}-cd"
oc policy add-role-to-user edit --serviceaccount jenkins -n "${PROJECT_ID}-cd"

echo "Allow to pull ${PROJECT_ID}-dev images from ${PROJECT_ID}-test"
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_ID}-test -n "${PROJECT_ID}-dev"

echo "Allow ${PROJECT_ID}-dev and ${PROJECT_ID}-test to pull ${PROJECT_ID}-cd images"
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_ID}-test -n "${PROJECT_ID}-cd"
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_ID}-dev -n "${PROJECT_ID}-cd"

echo "Grant serviceaccount 'default' role 'image-builder' to import images from other cluster"
oc policy add-role-to-user system:image-builder --serviceaccount default -n "${PROJECT_ID}-dev"
oc policy add-role-to-user system:image-builder --serviceaccount default -n "${PROJECT_ID}-test"

echo "Seed admins, by default only role 'dedicated-admin' has admin rights"
if [ -n ${PROJECT_ADMIN} ]; then
  for admin_user in $(echo $PROJECT_ADMIN | sed -e 's/,/ /g'); do
    echo "- seeding admin: ${admin_user}"
    oc policy add-role-to-user admin ${admin_user} -n "${PROJECT_ID}-dev"
    oc policy add-role-to-user admin ${admin_user} -n "${PROJECT_ID}-test"
    oc policy add-role-to-user admin ${admin_user} -n "${PROJECT_ID}-cd"
  done
fi

if [ -n ${PROJECT_GROUPS} ]; then
  echo "Seeding special permission groups"
  for group in $(echo $PROJECT_GROUPS | sed -e 's/,/ /g'); do
    groupName=$(echo $group | cut -d "=" -f1)
    groupValue=$(echo $group | cut -d "=" -f2)

    usergroup_role=edit
    admingroup_role=admin
    readonlygroup_role=view

    if [ ${groupValue} == "" ]; then
      continue
    fi

    echo "- seeding groups: ${groupName^^} - ${groupValue}"
    if [[ ${groupName^^} == *USERGROUP* ]]; then
      oc policy add-role-to-group ${usergroup_role} ${groupValue} -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group ${usergroup_role} ${groupValue} -n "${PROJECT_ID}-test"
      oc policy add-role-to-group ${usergroup_role} ${groupValue} -n "${PROJECT_ID}-cd"
    elif [[ ${groupName^^} == *ADMINGROUP* ]]; then
      oc policy add-role-to-group ${admingroup_role} ${groupValue} -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group ${admingroup_role} ${groupValue} -n "${PROJECT_ID}-test"
      oc policy add-role-to-group ${admingroup_role} ${groupValue} -n "${PROJECT_ID}-cd"
    elif [[ ${groupName^^} == *READONLYGROUP* ]]; then
      oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n "${PROJECT_ID}-dev"
      oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n "${PROJECT_ID}-test"
      oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n "${PROJECT_ID}-cd"
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
