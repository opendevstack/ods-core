#!/usr/bin/env bash
set -eu
set -o pipefail
# build-ods-ami-ssm.sh builds an ODS image using Packer over SSM.
# It depends on a prebuilt CentOS7 AMI which has SSM installed.
# To use this in your AWS account, you must have an IAM instance profile setup
# as described in https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html#instance-profile-add-permissions.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

iam_instance_profile="SSMInstanceProfile"
profile="default"
region="eu-west-1"
instance_type="m5ad.4xlarge"
ods_branch="master"

function usage {
    printf "Builds an ODS image using Packer over SSM.\n\n"
    printf "Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n\n"
    printf "\t-p|--profile\t\tAWS profile (defaults to: %s)\n" "${profile}"
    printf "\t-r|--region\t\tAWS region (defaults to: %s)\n" "${region}"
    printf "\t-i|--instance-type\tInstance type (defaults to: %s)\n" "${instance_type}"
    printf "\t-b|--branch\t\tODS branch (defaults to: %s)\n" "${ods_branch}"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -p|--profile) profile="$2"; shift;;
    -p=*|--profile=*) profile="${1#*=}";;

    -r|--region) region="$2"; shift;;
    -r=*|--region=*) region="${1#*=}";;

    -b|--ods-branch) ods_branch="$2"; shift;;
    -b=*|--ods-branch=*) ods_branch="${1#*=}";;

    -i|--instance-type) instance_type="$2"; shift;;
    -i=*|--instance-type=*) instance_type="${1#*=}";;

    *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

time packer build -on-error=ask \
    -var "iam_instance_profile=${iam_instance_profile}" \
    -var "profile=${profile}" \
    -var "region=${region}" \
    -var 'username=openshift' \
    -var 'password=openshift' \
    -var "name_tag=ODS Box $(date)" \
    -var "ods_branch=${ods_branch}" \
    -var "instance_type=${instance_type}" \
    "${SCRIPT_DIR}"/ods-ami-ssm.json
