#!/usr/bin/env bash
set -e

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-s|--trigger_secret\tTrigger Secret\n"
  printf "\t-k|--project_key\tProject Key (case sensitive)\n"
  printf "\t-bu|--bitbucket_url\tBitbucket Url\n"
  printf "\t-w|--webhook_proxy_url\tWebhook Proxy Url\n"
  printf "\t-c|--component_id\tComponent Id\n"
  printf "\t-b|--brach\tBranch\n"
  printf "\t-u|--username\tUsername\n"
  printf "\t-p|--password\tPassword\n"
  printf "\t-sh|--git_url_ssh\tGit Url SSH\n"
  printf "\t-ht|--git_url_http\tGit Url HTTP\n"
  printf "\t-gi|--group_id\tGroup Id\n"
  printf "\t-pn|--package_name\tPackage Name\n"
  printf "\t-on|--ods_namespace\tODS Namespace\n"
  printf "\t-op|--ods_bb_project\tODS Bitbucket Project\n"
  printf "\t-ot|--ods_image_tag\tODS Image Tag\n"
  printf "\t-or|--ods_git_ref\tODS Git Ref\n"
  printf "\t-ag|--admin_group\tAdmin Group\n"
  printf "\t-ug|--user_group\tUser Group\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -k=*|--project_key=*) PROJECT_KEY="${1#*=}";;
  -k|--project_key)     PROJECT_KEY="$2"; shift;;

  -s=*|--trigger_secret=*) TRIGGER_SECRET="${1#*=}";;
  -s|--trigger_secret)     TRIGGER_SECRET="$2"; shift;;

  -bu=*|--bitbucket_url=*) BITBUCKET_URL="${1#*=}";;
  -bu|--bitbucket_url)     BITBUCKET_URL="$2"; shift;;

  -w=*|--webhook_proxy_url=*) WEBHOOK_PROXY_URL="${1#*=}";;
  -w|--webhook_proxy_url)     WEBHOOK_PROXY_URL="$2"; shift;;

  -c=*|--component_id=*) COMPONENT_ID="${1#*=}";;
  -c|--component_id)     COMPONENT_ID="$2"; shift;;

  -b=*|--brach=*) BRANCH="${1#*=}";;
  -b|--brach)     BRANCH="$2"; shift;;

  -u=*|--username=*) BASIC_AUTH_USER="${1#*=}";;
  -u|--username)     BASIC_AUTH_USER="$2"; shift;;

  -p=*|--password=*) BASIC_AUTH_PWD="${1#*=}";;
  -p|--password)     BASIC_AUTH_PWD="$2"; shift;;

  -sh=*|--git_url_ssh=*) GIT_URL_SSH="${1#*=}";;
  -sh|--git_url_ssh)     GIT_URL_SSH="$2"; shift;;

  -ht=*|--git_url_http=*) GIT_URL_HTTP="${1#*=}";;
  -ht|--git_url_http)     GIT_URL_HTTP="$2"; shift;;

  -gi=*|--group_id=*) GROUP_ID="${1#*=}";;
  -gi|--group_id)     GROUP_ID="$2"; shift;;

  -pn=*|--package_name=*) PACKAGE_NAME="${1#*=}";;
  -pn|--package_name)     PACKAGE_NAME="$2"; shift;;

  -on=*|--ods_namespace=*) ODS_NAMESPACE="${1#*=}";;
  -on|--ods_namespace)     ODS_NAMESPACE="$2"; shift;;

  -op=*|--ods_bb_project=*) ODS_BITBUCKET_PROJECT="${1#*=}";;
  -op|--ods_bb_project)     ODS_BITBUCKET_PROJECT="$2"; shift;;

  -ot=*|--ods_image_tag=*) ODS_IMAGE_TAG="${1#*=}";;
  -ot|--ods_image_tag)     ODS_IMAGE_TAG="$2"; shift;;

  -or=*|--ods_git_ref=*) ODS_GIT_REF="${1#*=}";;
  -or|--ods_git_ref)     ODS_GIT_REF="$2"; shift;;

  -ag=*|--admin_group=*) ADMIN_GROUP="${1#*=}";;
  -ag|--admin_group)     ADMIN_GROUP="$2"; shift;;

  -ug=*|--user_group=*) USER_GROUP="${1#*=}";;
  -ug|--user_group)     USER_GROUP="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

# check required parameters
if [ -z "${TRIGGER_SECRET}" ]; then
  echo "TRIGGER_SECRET is unset"; usage
  exit 1
else
	echo "TRIGGER_SECRET=${TRIGGER_SECRET}"
fi

if [ -z "${PROJECT_KEY}" ]; then
  echo "PROJECT_KEY is unset"; usage
  exit 1
else
	echo "PROJECT_KEY=${PROJECT_KEY}"
fi

if [ -z "${BITBUCKET_URL}" ]; then
  echo "BITBUCKET_URL is unset"; usage
  exit 1
else
	echo "BITBUCKET_URL=${BITBUCKET_URL}"
fi

if [ -z "${WEBHOOK_PROXY_URL}" ]; then
  echo "WEBHOOK_PROXY_URL is unset"; usage
  exit 1
else
	echo "WEBHOOK_PROXY_URL=${WEBHOOK_PROXY_URL}"
fi

if [ -z "${COMPONENT_ID}" ]; then
  echo "COMPONENT_ID is unset"; usage
  exit 1
else
	echo "COMPONENT_ID=${COMPONENT_ID}"
fi

if [ -z "${BRANCH}" ]; then
  echo "BRANCH is unset"; usage
  exit 1
else
	echo "BRANCH=${BRANCH}"
fi

if [ -z "${BASIC_AUTH_USER}" ]; then
  echo "BASIC_AUTH_USER is unset"; usage
  exit 1
else
	echo "BASIC_AUTH_USER=${BASIC_AUTH_USER}"
fi

if [ -z "${BASIC_AUTH_PWD}" ]; then
  echo "BASIC_AUTH_PWD is unset"; usage
  exit 1
else
	echo "BASIC_AUTH_PWD=${BASIC_AUTH_PWD}"
fi

if [ -z "${GIT_URL_SSH}" ]; then
  echo "GIT_URL_SSH is unset"; usage
  exit 1
else
	echo "GIT_URL_SSH=${GIT_URL_SSH}"
fi

if [ -z "${GIT_URL_HTTP}" ]; then
  echo "GIT_URL_HTTP is unset"; usage
  exit 1
else
	echo "GIT_URL_HTTP=${GIT_URL_HTTP}"
fi

if [ -z "${GROUP_ID}" ]; then
  echo "GROUP_ID is unset"; usage
  exit 1
else
	echo "GROUP_ID=${GROUP_ID}"
fi

if [ -z "${PACKAGE_NAME}" ]; then
  echo "PACKAGE_NAME is unset"; usage
  exit 1
else
	echo "PACKAGE_NAME=${PACKAGE_NAME}"
fi

if [ -z "${ODS_NAMESPACE}" ]; then
  echo "ODS_NAMESPACE is unset"; usage
  exit 1
else
	echo "ODS_NAMESPACE=${ODS_NAMESPACE}"
fi

if [ -z "${ODS_BITBUCKET_PROJECT}" ]; then
  echo "ODS_BITBUCKET_PROJECT is unset"; usage
  exit 1
else
	echo "ODS_BITBUCKET_PROJECT=${ODS_BITBUCKET_PROJECT}"
fi

if [ -z "${ODS_IMAGE_TAG}" ]; then
  echo "ODS_IMAGE_TAG is unset"; usage
  exit 1
else
	echo "ODS_IMAGE_TAG=${ODS_IMAGE_TAG}"
fi

if [ -z "${ODS_GIT_REF}" ]; then
  echo "ODS_GIT_REF is unset"; usage
  exit 1
else
	echo "ODS_GIT_REF=${ODS_GIT_REF}"
fi

if [ -z "${ADMIN_GROUP}" ]; then
  echo "ADMIN_GROUP is unset"; usage
  exit 1
else
	echo "ADMIN_GROUP=${ADMIN_GROUP}"
fi

if [ -z "${USER_GROUP}" ]; then
  echo "USER_GROUP is unset"; usage
  exit 1
else
	echo "USER_GROUP=${USER_GROUP}"
fi

WEBHOOK_ENDPOINT="$WEBHOOK_PROXY_URL/build?trigger_secret=$TRIGGER_SECRET&jenkinsfile_path=release-manager/Jenkinsfile&component=ods-qs-$COMPONENT_ID"
echo "WEBHOOK_ENDPOINT=${WEBHOOK_ENDPOINT}"
COMPONENT_TYPE="release-manager"
REPO_NAME="$PROJECT_KEY-$COMPONENT_ID"
REPO_DESCRIPTION="Automatically created repository for project $PROJECT_KEY"

generate_provision_repo_post_data()
{
  cat <<EOF
{
  "env" : [ {
    "name" : "component_type",
    "value" : "$COMPONENT_TYPE"
  }, {
    "name" : "component_id",
    "value" : "$COMPONENT_ID"
  }, {
    "name" : "git_url_ssh",
    "value" : "$GIT_URL_SSH"
  }, {
    "name" : "git_url_http",
    "value" : "$GIT_URL_HTTP"
  }, {
    "name" : "GROUP_ID",
    "value" : "$GROUP_ID"
  }, {
    "name" : "PROJECT_ID",
    "value" : "$PROJECT_KEY"
  }, {
    "name" : "PACKAGE_NAME",
    "value" : "$PACKAGE_NAME"
  }, {
    "name" : "ODS_NAMESPACE",
    "value" : "$ODS_NAMESPACE"
  }, {
    "name" : "ODS_BITBUCKET_PROJECT",
    "value" : "$ODS_BITBUCKET_PROJECT"
  }, {
    "name" : "ODS_IMAGE_TAG",
    "value" : "$ODS_IMAGE_TAG"
  }, {
    "name" : "ODS_GIT_REF",
    "value" : "$ODS_GIT_REF"
  } ],
  "branch" : "$BRANCH",
  "repository" : "ods-quickstarters",
  "project" : "$ODS_BITBUCKET_PROJECT",
  "url" : "$WEBHOOK_ENDPOINT"
}
}
EOF
}

echo
echo "Calling the repository creation script"
sh ./create-bitbucket-repository.sh -k $PROJECT_KEY -n $REPO_NAME -b $BITBUCKET_URL -u $BASIC_AUTH_USER -p $BASIC_AUTH_PWD -ag $ADMIN_GROUP -ug $USER_GROUP

echo
echo
echo "Provision release manager repository ${REPO_NAME} for project ${PROJECT_KEY} through Webhook Proxy ${WEBHOOK_ENDPOINT}"
echo
echo "With post data: $(generate_provision_repo_post_data)"
echo

curl --silent \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --url "${WEBHOOK_ENDPOINT}" \
    --data "$(generate_provision_repo_post_data)"
