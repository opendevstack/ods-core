#!/bin/bash
set -eu
set -o pipefail

install=
target_git_ref=

instance_type="t2.2xlarge"
az="eu-west-1a"
volume_size="100"
ami_id=
host=
keypair=
instance_id=
security_group_id=
wait=

function usage {
  printf "Run tests in AWS.\n\n"
  printf "Usage:\n\n"
  printf "\t--help\t\t\tPrint usage\n"
  printf "\t--verbose\t\tEnable verbose mode\n"
  printf "\n"
  printf "\t--keypair\t\tName of keypair (required)\n"
  printf "\n"
  printf "\t--host\t\t\tHost (bypasses launching a new instance)\n"
  printf "\n"
  printf "\t--instance-id\t\tInstance ID (bypasses creating a new instance)\n"
  printf "\n"
  printf "\t--instance-type\t\tInstance Type (defaults to '%s', used if neither --instance-id nor --host are given)\n" "${instance_type}"
  printf "\t--security-group-id\tSecurity Group with SSH access allowed (required if neither --instance-id nor --host are given)\n"
  printf "\t--availability-zone\tAZ (defaults to '%s', used if neither --instance-id nor --host are given)\n" "${az}"
  printf "\t--ami-id\t\tAMI ID (defaults to latest ubuntu-xenial-16.04, used if neither --instance-id nor --host are given)\n"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --target-git-ref) target_git_ref="$2"; shift;;
  --target-git-ref=*) target_git_ref="${1#*=}";;

  --instance-id) instance_id="$2"; shift;;
  --instance-id=*) instance_id="${1#*=}";;

  --instance-type) instance_type="$2"; shift;;
  --instance-type=*) instance_type="${1#*=}";;

  --security-group-id) security_group_id="$2"; shift;;
  --security-group-id=*) security_group_id="${1#*=}";;

  --host) host="$2"; shift;;
  --host=*) host="${1#*=}";;

  --keypair) keypair="$2"; shift;;
  --keypair=*) keypair="${1#*=}";;

  --availability-zone) az="$2"; shift;;
  --availability-zone=*) az="${1#*=}";;

  --ami-id) ami_id="$2"; shift;;
  --ami-id=*) ami_id="${1#*=}";;

  --install) install="yes";;

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! which aws &> /dev/null; then
  echo "ERROR: Install aws-cli: https://docs.aws.amazon.com/de_de/cli/latest/userguide/cli-chap-install.html"
  exit 1
fi

if ! which jq &> /dev/null; then
  echo "ERROR: Install jq: https://stedolan.github.io/jq/download/"
  exit 1
fi

if [  -z "$keypair" ]; then
    echo "--key-name not given, setting to default edp_dublin_keypair."
    keypair=edp_dublin_keypair
fi

if [ -z "${host}" ]; then
  if [ -z "${instance_id}" ]; then
    if [ -z "${security_group_id}" ]; then
      echo "--security-group-id not given. Using default sg-006935bec03a154a1"
      security_group_id=sg-006935bec03a154a1
    fi
    if [ -z "${keypair}" ]; then
      echo "ERROR: --key-name not given."
      exit 1
    fi
    if [ -z "${ami_id}" ]; then
        if [[ -n "${install}" ]]
        then
            ami_id=$(aws ec2 describe-images \
                --owners 275438041116 \
                --filters "Name=name,Values=EDP in a box 2020-05-30" "Name=root-device-type,Values=ebs" \
                --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')
            echo "You are in install mode using CentOS 7 image ${ami_id}."
        else
            ami_id=$(aws ec2 describe-images \
                --owners 275438041116 \
                --filters "Name=name,Values=ODS in a box" "Name=root-device-type,Values=ebs" \
                --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')
            echo "You are in test mode using ODS in a box image ${ami_id}."
        fi
    fi
    echo "Launching temporary instance (${instance_type}) with AMI=${ami_id} with security_group=${security_group_id} ..."
    echo "Boot instance"
    instance_id=$(aws ec2 run-instances --image-id "$ami_id" \
    --count 1 \
    --instance-type "${instance_type}" \
    --key-name "${keypair}" \
    --security-group-ids "$security_group_id" \
    --block-device-mappings "[{ \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": ${volume_size} } }]" \
    | jq -r '.Instances[0].InstanceId')
    echo "Created instance with ID=${instance_id}, waiting for it to be running ..."
    aws ec2 wait instance-running --instance-ids "$instance_id"
    echo "Instance with ID=${instance_id} running"

    ec2_instance_name="ODS in a box $(date)"
    aws ec2 create-tags --resources "${instance_id}" --tags "Key=Name,Value=${ec2_instance_name}"
    echo "Starting new EC2 instance with name ${ec2_instance_name}"

    wait="yes"
  fi

  echo "Get IP address"
  host=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
  echo "Instance has address=${host}"
fi

if [ -n "${wait}" ]; then
    echo -n "Waiting for ODS Box instance ${instance_id} to become available."
    instance_state=$(aws ec2 describe-instance-status --instance-ids  "${instance_id}" | jq ".InstanceStatuses[].SystemStatus.Details[].Status")
    while [[ ${instance_state} != \"passed\" ]]
    do
        echo -n "."
        sleep 5
        instance_state=$(aws ec2 describe-instance-status --instance-ids  "${instance_id}" | jq ".InstanceStatuses[].SystemStatus.Details[].Status")
    done
    echo "available."
fi

target_git_ref="${target_git_ref:-master}"

if [ -n "${install}" ]; then
    echo "Now installing ODS"
    rsync bootstrap.sh "openshift@${host}:/home/openshift/bin/bootstrap"
    echo "Running bootstrap on AWS EC2 instance to build ODS from branch ${target_git_ref}"
    ssh -t "openshift@${host}" -- '${HOME}/bin/bootstrap' "--branch ${target_git_ref}"
else
    echo "Now starting ODS"
    ssh -t "openshift@${host}" -- '${HOME}/opendevstack/ods-core/ods-devenv/scripts/deploy.sh --target startup_ods'
fi
