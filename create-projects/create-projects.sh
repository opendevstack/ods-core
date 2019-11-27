#!/bin/#!/usr/bin/env bash
set -ex

# check required parameters
if [ -z ${PROJECT_ID+x} ]; then
    echo "PROJECT_ID is unset";
    exit 1;
else echo "PROJECT_ID=${PROJECT_ID}"; fi

oc new-project ${PROJECT_ID}-cd
oc new-project ${PROJECT_ID}-dev
oc new-project ${PROJECT_ID}-test

echo "set admin permissions for the Jenkins SA on the project(s)"
echo "this is needed to clone an entire project including role bindings for autocloneEnv in the shared lib"
JENKINS_ROLE=admin

echo "allow jenkins from CD project to admin the environment projects"
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT_ID}-cd:jenkins -n ${PROJECT_ID}-dev
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT_ID}-cd:jenkins -n ${PROJECT_ID}-test

echo "allow webhook proxy to create a pipeline BC in the +cd project"
oc policy add-role-to-user edit -z default -n ${PROJECT_ID}-cd

echo "seed jenkins SA with edit roles in CD project / to even run jenkins"
oc policy add-role-to-user edit -z jenkins -n ${PROJECT_ID}-cd

echo "allow test users to pull dev images"
oc policy add-role-to-group system:image-puller system:serviceaccounts:${PROJECT_ID}-test -n $PROJECT_ID-dev

echo "image-builder for sa default needed to import images from other cluster"
oc policy add-role-to-user system:image-builder -z default -n ${PROJECT_ID}-dev
oc policy add-role-to-user system:image-builder -z default -n ${PROJECT_ID}-test
echo "seed admins, by default only role dedicated-admin has admin rights"
if [[ ! -z ${PROJECT_ADMIN} ]]; then
	for admin_user in $(echo $PROJECT_ADMIN | sed -e 's/,/ /g');
	do
		echo "- seeding admin: ${admin_user}"
		oc policy add-role-to-user admin ${admin_user} -n ${PROJECT_ID}-dev
		oc policy add-role-to-user admin ${admin_user} -n ${PROJECT_ID}-test
		oc policy add-role-to-user admin ${admin_user} -n ${PROJECT_ID}-cd
	done
fi

if [[ ! -z ${PROJECT_GROUPS} ]]; then
	echo "seeding special permission groups"
	for group in $(echo $PROJECT_GROUPS | sed -e 's/,/ /g');
	do
		groupName=$(echo $group | cut -d "=" -f1)
		groupValue=$(echo $group | cut -d "=" -f2)

		usergroup_role=edit
		admingroup_role=admin
		readonlygroup_role=view

		if [[ ${groupValue} == "" ]];
		then
			continue
		fi

		echo "- seeding groups: ${groupName^^} - ${groupValue}"
		if [[ ${groupName^^} == *USERGROUP* ]]; then
			oc policy add-role-to-group ${usergroup_role} ${groupValue} -n ${PROJECT_ID}-dev
			oc policy add-role-to-group ${usergroup_role} ${groupValue} -n ${PROJECT_ID}-test
			oc policy add-role-to-group ${usergroup_role} ${groupValue} -n ${PROJECT_ID}-cd
		elif [[ ${groupName^^} == *ADMINGROUP* ]]; then
			oc policy add-role-to-group ${admingroup_role} ${groupValue} -n ${PROJECT_ID}-dev
			oc policy add-role-to-group ${admingroup_role} ${groupValue} -n ${PROJECT_ID}-test
			oc policy add-role-to-group ${admingroup_role} ${groupValue} -n ${PROJECT_ID}-cd
		elif [[ ${groupName^^} == *READONLYGROUP* ]]; then
			oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n ${PROJECT_ID}-dev
			oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n ${PROJECT_ID}-test
			oc policy add-role-to-group ${readonlygroup_role} ${groupValue} -n ${PROJECT_ID}-cd
		fi
	done
else
	echo "- seeding default edit/view rights for system:authenticated"
	oc policy add-role-to-group edit system:authenticated -n $PROJECT_ID-dev
	oc policy add-role-to-group edit system:authenticated -n $PROJECT_ID-test
	oc policy add-role-to-group edit system:authenticated -n $PROJECT_ID-cd

	echo "allow all authenticated users to view the project"
	oc policy add-role-to-group view system:authenticated -n $PROJECT_ID-dev
	oc policy add-role-to-group view system:authenticated -n $PROJECT_ID-test
	oc policy add-role-to-group view system:authenticated -n $PROJECT_ID-cd
fi

