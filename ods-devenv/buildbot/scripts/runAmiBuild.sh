#!/usr/bin/env bash
# Per default this script will build a new AMI on AWS for the ODS master branch.
# The branch can be overridden to build e.g. 3.x. Caveat: the stated branch must
# exist on each of the following repositories:
# ods-core, ods-quickstarters, ods-jenkins-shared-library, not necessarily in ods-document-generation-templates
set -exu
echo "Running runAmiBuild.sh"
pub_key=
targetGitRef="master"
readonly repository=ods-core
readonly odsCoreClonePath=https://github.com/opendevstack/ods-core

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --target_git_ref) targetGitRef="$2"; shift;;
  --build_path) buildPath="$2"; shift;;
  --log_path) logPath="$2"; shift;;
  --instance_type) instanceType="$2"; shift;;
  --aws_access_key) awsAccessKey="$2"; shift;;
  --aws_secret_access_key) awsSecretAccessKey="$2"; shift;;
  --pub-key) pub_key="$2"; shift;;

esac; shift; done

export PACKER_LOG=1
export AWS_MAX_ATTEMPTS=400
export AWS_POLL_DELAY_SECONDS=15
date

mkdir -p "${buildPath:?}"
cd "${buildPath}" || exit

# prepare build folder
readonly targetGitRefForPath=$(echo -n "${targetGitRef:?}" | tr "/" "_")
if [[ -d "${targetGitRefForPath}" ]]
then
  # clean up stale folder from previous builds
  rm -rf "${targetGitRefForPath}"
fi
mkdir -p "${targetGitRefForPath}"
cd "${targetGitRefForPath}"
git clone "${odsCoreClonePath}"
cd "${repository}"
if ! git checkout "${targetGitRef}" &> /dev/null
then
  echo "Branch to build ${targetGitRef} could not be checked out, please fix the configuration!"
  exit 1
fi

# prepare logs
mkdir -p "${logPath:?}"
readonly logFile="${logPath:?}/build_$(echo "${targetGitRef:?}" | tr "/" "_")_$(date +%Y%m%dT%H%M%S).log"
rm -f "${logPath}/current_${targetGitRefForPath}.log"
ln -s "${logFile}" "${logPath}/current_${targetGitRefForPath}.log"

# run packer build
time bash 2>&1 ods-devenv/packer/create_ods_box_image.sh --target create_ods_box_ami --aws-access-key "${awsAccessKey:?}" --aws-secret-key "${awsSecretAccessKey:?}" --ods-branch "${targetGitRef}" --pub-key "${pub_key}" --instance-type "${instanceType:?}" | tee "${logFile}"

# clean up after build
cd ../..
rm -rf "${targetGitRefForPath}"
