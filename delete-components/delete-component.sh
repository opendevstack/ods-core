#!/usr/bin/env bash

# This deletes the resource objects for a certain component:
# * image streams
# * build configs: pipelines
# * build configs: images
# * services
# * routes

# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example)# This script sets up the resource objects for a certain component:
# * image streams
# * build configs: pipelines
# * build configs: images
# * services
# * routes

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
    -c|--component)
    COMPONENT="$2"
    shift # past argument
    ;;
    -b|--bitbucket)
    BITBUCKET_REPO="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [ -z ${PROJECT+x} ]; then
    echo "PROJECT is unset, but required";
    exit 1;
else echo "PROJECT=${PROJECT}"; fi
if [ -z ${COMPONENT+x} ]; then
    echo "COMPONENT is unset, but required";
    exit 1;
else echo "COMPONENT=${COMPONENT}"; fi

# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -p|--project)
    PROJECT="$2"
    shift # past argument
    ;;
    -c|--component)
    COMPONENT="$2"
    shift # past argument
    ;;
    -b|--bitbucket)
    BITBUCKET_REPO="$2"
    shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

if [ -z ${PROJECT+x} ]; then
    echo "PROJECT is unset, but required";
    exit 1;
else echo "PROJECT=${PROJECT}"; fi
if [ -z ${COMPONENT+x} ]; then
    echo "COMPONENT is unset, but required";
    exit 1;
else echo "COMPONENT=${COMPONENT}"; fi

if [ -z ${ROUTE_NAME+x} ]; then
    echo "ROUTE_NAME is unset, using default ${COMPONENT}";
else
    echo "ROUTE_NAME=${ROUTE_NAME}";
fi

for devenv in dev test ; do
	oc project ${PROJECT}-${devenv}
	echo "deleting component environment"
    oc process cd//component-environment PROJECT=${PROJECT} COMPONENT=${COMPONENT} ENV=${devenv} | oc delete -n ${PROJECT}-${devenv} -f-
	echo "deleting route"
    oc process cd//component-route PROJECT=${PROJECT} COMPONENT=${COMPONENT} ENV=${devenv} | oc delete -n ${PROJECT}-${devenv} -f-
	echo "deleting environment bc"
    oc process cd//bc-docker PROJECT=${PROJECT} COMPONENT=${COMPONENT} ENV=${devenv} | oc delete -n ${PROJECT}-${devenv} -f-
done