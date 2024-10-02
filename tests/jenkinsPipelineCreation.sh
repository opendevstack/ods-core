#!/usr/bin/env bash
set -eux

PROJECT=""
QuickstarterRepository=""
configurationRef=""
SONAR_QUALITY_PROFILE=""
ODS_GIT_REF="$ODS_GIT_REF"
BITBUCKET_URL="$BITBUCKET_URL"
ODS_NAMESPACE="$ODS_NAMESPACE"
ODS_IMAGE_TAG="$ODS_IMAGE_TAG"
ODS_BITBUCKET_PROJECT="$ODS_BITBUCKET_PROJECT"

# Override ods configuration (optional)
while [[ "$#" > 0 ]]; do case $1 in
  -g=*|--ods-git-ref=*) ODS_GIT_REF="${1#*=}";;
  -g|--ods-git-ref) ODS_GIT_REF="$2"; shift;;

  -c=*|--configurationRef=*) configurationRef="${1#*=}";;
  -c|--configurationRef) configurationRef="$2"; shift;;

  -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;
  -b|--bitbucket) BITBUCKET_URL="$2"; shift;;

  -n=*|--ods-namespace=*) ODS_NAMESPACE="${1#*=}";;
  -n|--ods-namespace) ODS_NAMESPACE="$2"; shift;;

  -i=*|--ods-image-tag=*) ODS_IMAGE_TAG="${1#*=}";;
  -i|--ods-image-tag) ODS_IMAGE_TAG="$2"; shift;;
  
  -m=*|--bitbucket-ods-project=*) ODS_BITBUCKET_PROJECT="${1#*=}";;
  -m|--bitbucket-ods-project) ODS_BITBUCKET_PROJECT="$2"; shift;;

  -p=*|--project=*) PROJECT="${1#*=}";;
  -p|--project) PROJECT="$2"; shift;;

  -q=*|--quickstarter-repository=*) QuickstarterRepository="${1#*=}";;
  -q|--quickstarter-repository) QuickstarterRepository="$2"; shift;;

  -s=*|--sonar-quality-profile=*) SONAR_QUALITY_PROFILE="${1#*=}";;
  -s|--sonar-quality-profile) SONAR_QUALITY_PROFILE="$2"; shift;;  

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# echo "create trigger secret"
# SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

tailor --namespace=${PROJECT}-cd --non-interactive \
  apply \
  --param=ODS_GIT_REF=${ODS_GIT_REF} \
  --param=configurationRef=${configurationRef} \
  --param=PROJECT=${PROJECT} \
  --param=BITBUCKET_URL=${BITBUCKET_URL} \
  --param=ODS_NAMESPACE=${ODS_NAMESPACE} \
  --param=ODS_IMAGE_TAG=${ODS_IMAGE_TAG} \
  --param=ODS_BITBUCKET_PROJECT=${ODS_BITBUCKET_PROJECT} \
  --param=SONAR_QUALITY_PROFILE="${SONAR_QUALITY_PROFILE}" \
  --param=QuickstarterRepository=${QuickstarterRepository} \
  --selector template=golden-test-pipeline
