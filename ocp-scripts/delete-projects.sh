#!/usr/bin/env bash
# This script creates the 3 OCP projects we currently require for every
# ODS project.

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -p|--project)
    PROJECT="$2"
    shift # past argument
    ;;
    *)
        echo "Unknown option: $1. Exiting in case you did not intend to invoke this script."
        exit 1
    ;;
esac
shift # past argument or value
done

if [ -z ${PROJECT+x} ]; then
    echo "PROJECT is unset";
    exit 1;
else echo "PROJECT=${PROJECT}"; fi

oc delete project ${PROJECT}-cd
oc delete project ${PROJECT}-dev
oc delete project ${PROJECT}-test

