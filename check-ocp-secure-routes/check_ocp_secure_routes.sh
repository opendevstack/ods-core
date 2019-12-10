#!/bin/bash
# this script checks for non secured routes for OpenDevStack in OpenShift
#

# if projects is set - just return those
if [ -z "${OD_OCP_PROJECTS+x}" ]; then
	oc get project --no-headers > oc_projects
else
	echo "Project filter set: ${OD_OCP_PROJECTS}"
	oc get project --no-headers | grep ${OD_OCP_PROJECTS} > oc_projects
fi

numberProjects=$(cat oc_projects | wc -l)

echo "Evaluating ${numberProjects} project(s) for insecure routes ... "

while IFS= read line
do
	project_config=($line)
	project=${project_config[0]}

	# skip the system ones

	if [[ "$project" == "default" || "$project" == "logging" || "$project" == "openshift-infra" ]]; then
		continue
	fi

	oc project ${project} >& /dev/null
	echo "scanning project: ${project}"

	oc get routes --no-headers | sed -e "s/  */ /g" | cut -d ' ' -f1,5,6 > routes

	allsecure=true

	while IFSRT= read lineRoute
	do
		route_config=($lineRoute)
		route=${route_config[0]}
		termi=${route_config[1]}
		# hack for bad returns from OC cli
		termi2=${route_config[2]}
		if [[ ! "$termi" ==  *"edge"* && ! "$termi2" ==  *"edge"* && ! "$termi" ==  *"passthrough"* && ! "$termi2" ==  *"passthrough"* && ! "$termi" ==  *"reencrypt"* && ! "$termi2" ==  *"reencrypt"* ]]; then
			echo " !!!! Route: ${route} is INSECURE! setting: ${termi} / ${termi2}"
			allsecure=false
		fi
	done <"routes";

	rm routes

	if [ "${allsecure}" == "false" ]; then
		failed_security_check=${failed_security_check}_${project}
	fi

	# line feed
	echo ""

done <"oc_projects";

rm oc_projects

if [ ! -z ${failed_security_check} ]; then
	echo "security check failed! - offending projects"


	for failedProject in $(echo $failed_security_check | sed -e 's/_/ /g');
	do
		echo "Project ${failedProject}"
	done

	exit 1
fi
