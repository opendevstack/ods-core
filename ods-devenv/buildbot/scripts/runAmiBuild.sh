#!/usr/bin/env bash
# Per default this script will build a new AMI on AWS for the ODS master branch.
# The branch can be overridden to build e.g. 3.x. Caveat: the stated branch must
# exist on each of the following repositories: 
# ods-core, ods-jenkins-shared-library, 
set -exu

targetGitRef="master"

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --target-git-ref) targetGitRef="$2"; shift;;
  --build_path) buildPath="$2"; shift;;
  --log_path) logPath="$2"; shift;;
  --instance_type) instanceType="$2"; shift;;
  --aws_access_key) awsAccessKey="$2"; shift;;
  --aws_secret_access_key) awsSecretAccessKey="$2"; shift;;

esac; shift; done

export PACKER_LOG=1
export AWS_MAX_ATTEMPTS=400
export AWS_POLL_DELAY_SECONDS=15
# source "${HOME}/.packerrc"

cd "${buildPath:?}" || exit
date
mkdir -p "${logPath:?}"
logFile="${logPath:?}/build_$(echo "${targetGitRef}" | tr "/" "_")_$(date +%Y%m%dT%H%M%S).log"
rm -f "${logPath}/current_${targetGitRef}.log"
ln -s "${logFile}" "${logPath}/current_${targetGitRef}.log"
time bash 2>&1 ods-devenv/packer/create_ods_box_image.sh --target create_ods_box_ami --aws-access-key "${awsAccessKey}" --aws-secret-key "${awsSecretAccessKey}" --ods-branch "${targetGitRef}" --instance-type "${instanceType}" | tee "${logFile:?}"
