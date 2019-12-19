#!/bin/bash

usage() {
cat << USAGE >&2
Usage example: [PROJECT_GREP=sample] ${0##*/} [--cheat] | tee results.txt

Will list projects http status in the following format:

scanning project: atest-cd
RESULT 403 atest-cd https://jenkins-atest-cd.example.openshiftapps.com
RESULT 401 atest-cd https://webhook-proxy-atest-cd.example.openshiftapps.com
...

To restrict the projects to list you can set a grep pattern in the
PROJECT_GREP environment variable

Invoke with --cheat to get some example of how to process the
output in bash.
USAGE
}

usage_and_exit() {
	usage
	exit 1
}

cheat_and_exit() {
usage
cat << CHEAT >&2

The results are meant to be investigated like so:

For a summary count of HTTP status codes:
$ cat results.txt | grep RESULT| cut -d ' ' -f2 | sort | uniq -c
   4 000
  23 200
  10 302
  36 401
  42 403
   4 404
   1 500
   1 502
   4 503

Note 000 means curl to the route failed and there is no HTTP response at all.

Assuming one wants to ignore certain status codes one can filter as
follows:

$ cat results.txt | grep RESULT | grep -v -e 50. -e 404 -e 000 | cut -d ' ' -f2 | sort | uniq -c
  23 200
  10 302
  36 401
  42 403

To identify routes with a certain status code:
$ cat results.txt | grep RESULT | grep 403 | cut -d ' ' -f3 -f4
atest-cd https://jenkins-atest-cd.example.openshiftapps.com
...
CHEAT
exit 0
}

[ "z$1" == "z--cheat" ] && cheat_and_exit

[ $# -eq 0 ] || usage_and_exit

set -e
oc whoami > /dev/null || (echo "Please log into openshift using oc login." && exit 1)
set +e

# if projects is set - just return those
if [ -z "${PROJECT_GREP+x}" ]; then
	oc get project --no-headers > oc_projects
else
	echo "Project filter set: ${PROJECT_GREP}"
	oc get project --no-headers | grep ${PROJECT_GREP} > oc_projects
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

	oc get routes --no-headers -n ${project} | sed -e "s/  */ /g" | cut -d ' ' -f2 > routes

	codes=( )
	while IFSRT= read lineRoute
	do
		url="https://${lineRoute}"
		http_code=$(curl -s -o /dev/null -w '%{http_code}' $url)
		codes+=( "RESULT $http_code $project $url" )
	done <"routes";

	for other in "${codes[@]}"; do
		echo "$other"
	done
done <"oc_projects";


echo "Tipp: get bash cheats with:  ${0}"
