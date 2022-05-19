#!/bin/bash
set -eu
set -o pipefail

install=
target_git_ref=

instance_type="m5ad.4xlarge"
volume_size=150
ami_id=
host=
keypair=
instance_id=
security_group_id=
wait=
subnet_id=
iam_instance_profile=

function usage {
  printf "Setup and run ODS in a box on AWS.\n\n"
  printf "To start ODS in a box from the prepared AMI run:\n"
  printf "./run-on-aws.sh\n\n"
  printf "To setup and start a fresh ODS in a box instance from master, run:\n"
  printf "./run-on-aws.sh --install\n\n"
  printf "To setup and start a fresh ODS in a box instance from a specific branch, run:\n"
  printf "note: the given branch name must exist on ods-core, ods-jenkins-shared-library and ods-quickstarters\n"
  printf "./run-on-aws.sh --install --target-git-ref my-branch-name\n\n"
  printf "Usage:\n\n"
  printf "\t--help\t\t\tPrint usage\n"
  printf "\t--verbose\t\tEnable verbose mode\n"
  printf "\n"
  printf "\t--target-git-ref\tThe git branch to build against, defaults to master\n"
  printf "\n"
  printf "\t--keypair\t\tName of keypair (required)\n"
  printf "\t--ami-id\t\tIf you brought your own CentOS 7 base image, specify its image-id here\n"
  printf "\t--host\t\t\tHost (bypasses launching a new instance)\n"
  printf "\t--instance-id\t\tInstance ID (bypasses creating a new instance)\n"
  printf "\t--instance-type\t\tInstance Type (defaults to '%s', used if neither --instance-id nor --host are given)\n" "${instance_type}"
  printf "\t--security-group-id\tSecurity Group with SSH access allowed - there is a reasonable default\n"
  printf "\t--subnet-id\tThe AWS subnet the EC2 instance shall be deployed in. This also implicitly determines the VPC.\n"
  printf "\t--iam-instance-profile\tSpecify the Arn if you want to connect to the EC2 instance using an AWS SSM session manager\n"
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

  --subnet-id) subnet_id="$2"; shift;;
  --subnet-id=*) subnet_id="${1#*=}";;

  --iam-instance-profile) iam_instance_profile="$2"; shift;;
  --iam-instance-profile=*) iam_instance_profile="${1#*=}";;

  --host) host="$2"; shift;;
  --host=*) host="${1#*=}";;

  --keypair) keypair="$2"; shift;;
  --keypair=*) keypair="${1#*=}";;

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

if [[  -z "$keypair" ]]; then
    echo "--key-name not given, setting to default edp_dublin_keypair."
    keypair=edp_dublin_keypair
fi

target_git_ref="${target_git_ref:-master}"

if [[ -z "${host}" ]]; then
  if [[ -z "${instance_id}" ]]; then
    if [[ -z "${security_group_id}" ]] && [[ -z "${iam_instance_profile}" ]]; then
      echo "Neither --security-group-id nor --iam-instance-profile specified. Using default sg-006935bec03a154a1"
      security_group_id=sg-006935bec03a154a1
    fi
    if [[ -z "${keypair}" ]]; then
      echo "ERROR: --key-name not given."
      exit 1
    fi
    if [[ -z "${ami_id}" ]]; then
        if [[ -n "${install}" ]]; then
            ami_id=$(aws ec2 describe-images \
                --owners 275438041116 \
                --filters "Name=name,Values=import-ami-*" "Name=root-device-type,Values=ebs" "Name=tag:Name,Values=CentOS*" \
                --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')
            echo "You are in install mode using CentOS 7 image ${ami_id}."
        else
            ami_id=$(aws ec2 describe-images \
                --owners 275438041116 \
                --filters "Name=name,Values=ODS in a Box ${target_git_ref} *" "Name=root-device-type,Values=ebs" "Name=tag:Name,Values=${instance_type}*" \
                --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')
            echo "You are in startup mode using ODS in a box image ${ami_id}."
        fi
    fi

    user_name="$(aws iam get-user | jq -r '.User.UserName')"
    ec2_instance_name="${user_name}: ODS-in-a-Box (${target_git_ref}) $(date '+%Y-%m-%d %H:%M:%S')"

    if [[ -z "${ami_id}" ]] || [[ "${ami_id}" == "null" ]]
    then
      echo "It looks like we have no AMI image ready for the git ref ${target_git_ref}!"
      echo "You may want to specify a branch name with --target-git-ref some-branch-name"
      echo "Stopping script execution now."
      exit 1
    fi

    echo "Launching EC2 instance (${instance_type}) using AMI=${ami_id} and security_group=${security_group_id} ..."
    echo "Boot instance"

    arg_list=
    if [[ -n "${subnet_id}" ]]
    then
        arg_list="--subnet-id ${subnet_id} "
    fi
    if [[ -n "${iam_instance_profile}" ]]
    then
        arg_list="${arg_list} --iam-instance-profile Arn=${iam_instance_profile} "
    fi
    if [[ -n "${security_group_id}" ]]
    then
        arg_list="${arg_list} --security-group-ids ${security_group_id} "
    fi

    echo "using arguments ${arg_list}"

    instance_id=$(aws ec2 run-instances --image-id "$ami_id" \
    ${arg_list} \
    --count 1 \
    --instance-type "${instance_type}" \
    --key-name "${keypair}" \
    --block-device-mappings "[{ \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": ${volume_size} } }]" \
    | jq -r '.Instances[0].InstanceId')
    echo "Created instance with ID=${instance_id}, waiting for it to be running ..."
    aws ec2 wait instance-running --instance-ids "$instance_id"
    echo "Instance with ID=${instance_id} running"
    
    aws ec2 create-tags --resources "${instance_id}" --tags "Key=Name,Value=${ec2_instance_name}"
    echo "Started new EC2 instance with name \"${ec2_instance_name}\""

    wait="yes"
  fi

  host=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
  echo "Instance has public IP address ${host}"
fi

if [[ -n "${wait}" ]]; then
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

if [[ -n "${install}" ]]; then
    echo "Now installing ODS"
    rsync bootstrap.sh "openshift@${host}:/home/openshift/bin/bootstrap"
    echo "Running bootstrap on AWS EC2 instance to build ODS from branch ${target_git_ref}"
    ssh -t "openshift@${host}" -- '${HOME}/bin/bootstrap' "--branch ${target_git_ref}"
else
    echo "Your new ODS box was provisioned!"
    echo "ODS will start as a service. Please allow the box some minutes to become ready, though."
    echo "You can track progress by logging into your new ODS box and running:"
    echo "  sudo journalctl -fu ods.service"
    echo "  or"
    echo "  sudo systemctl status ods.service"
fi

public_dns=$(aws ec2 describe-instances --instance-ids "${instance_id}" --query 'Reservations[].Instances[].PublicDnsName' --output text)
echo "ODS Box is available in EC2 instance ${instance_id} at ${public_dns}"
echo "You can log into your new ODS Box by running:"
echo "ssh openshift@${public_dns}"
echo "or, if you have configured the required AWS IAM roles:"
echo "aws ssm start-session --target ${instance_id} --document-name AWS-StartPortForwardingSession --parameters '{\"portNumber\":[\"22\"], \"localPortNumber\":[\"48022\"]}'"
echo "ssh openshift@localhost -p 48022"
echo
echo "Have fun!"
echo
