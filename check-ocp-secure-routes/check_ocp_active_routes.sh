#!/bin/bash
# set -x

# if projects is set - just return those
if [ -z "${OD_OCP_PROJECTS+x}" ]; then
	oc get project --no-headers > oc_projects
else
	echo "Project filter set: ${OD_OCP_PROJECTS}"
	oc get project --no-headers | grep ${OD_OCP_PROJECTS} > oc_projects
fi

while IFS= read line
do
	project_config=($line)
	project=${project_config[0]}
	echo "scanning project: ${project}"

	# skip the system ones
	if [[ "$project" == "default" || "$project" == "logging" || "$project" == "openshift-infra" ]]; then
		continue
	fi

	oc project ${project} >& /dev/null
	oc get routes --no-headers | sed -e "s/  */ /g" | cut -d ' ' -f2 > routes

	codes=( )
	while IFSRT= read lineRoute
	do
		url="https://${lineRoute}"
		http_code=$(curl -s -o /dev/null -w '%{http_code}' $url)
		codes+=( "RESULT:$http_code:$url:$project" )
	done <"routes";

	for other in "${codes[@]}"; do
		echo "$other"
	done
done <"oc_projects";



