#!/usr/bin/env bash

echo " "

function clean_containers {
	echo "Removing docker containers no more used... "
	if docker ps -a | grep -q 'Exited .* ago' ; then
	    docker ps -a | grep 'Exited .* ago'
	    echo " "
	    echo "Removing docker containers: "
	    docker ps -a | grep 'Exited .* ago' | sed 's/\s\+/ /g' | cut -d ' ' -f 1 | while read id; do echo "docker rm $id"; docker rm $id; done
	else
	    echo "No docker containers to remove. "
	fi
}

function clean_tests {
	echo "Removing tests projects no more used... "
	oc projects | grep '^\s*tes.*' | grep -v "${OMIT_TESTS_PROJECT}" | while read -r line; do
		if [ ! -z "$line" ]; then
			echo "Removing project ${line}: oc delete project $line "
			oc delete project $line || true
		else
			echo "No projects to remove"
		fi
	done
}

function clean_odsverify {
	if [ "true" == "$CLEAN_ODS_VERIFY" ]; then
		echo "Removing ODS VERIFY projects..."
		oc projects | grep '^\s*odsverify.*' | while read -r line; do
			if [ ! -z "$line" ]; then
				echo "Removing project ${line}: oc delete project $line "
				oc delete project $line || true
			else
				echo "No projects to remove"
			fi
		done
	fi
}

function clean_images {
    echo "oc adm prune images --keep-tag-revisions=1 --keep-younger-than=30m --confirm"
	oc adm prune images --keep-tag-revisions=1 --keep-younger-than=30m --confirm || true
}

function usage {
	ME=$(basename $0)
	echo " "
	echo "usage: ${ME} [--odsVerify] [--omitTestsProject tes22]"
	echo " "
}

function echo_error() {
	echo "$1"
	exit 1
}

OMIT_TESTS_PROJECT=none
CLEAN_ODS_VERIFY="false"

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    --odsVerify) CLEAN_ODS_VERIFY="true";;

    --omitTestsProject) OMIT_TESTS_PROJECT="$2"; echo "Tests to omit: $OMIT_TESTS_PROJECT"; shift;;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

clean_containers
clean_tests
clean_odsverify
clean_images

echo " "
exit 0
