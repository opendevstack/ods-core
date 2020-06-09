#!/bin/bash
set -eu
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

instance_type="t2.micro"
az="eu-west-1a"
volume_size="32"
ami_id=""
host=""
subnet_id=""
keypair=""
instance_id=""
security_group_id=""
prepare_test=""
rsync=""
wait=""
strictHostKeyChecking="-oStrictHostKeyChecking=no"

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
  printf "\t--subnet-id\t\tSubnet ID of a subnet with public DNS (required if neither --instance-id nor --host are given)\n"
  printf "\t--security-group-id\tSecurity Group with SSH access allowed (required if neither --instance-id nor --host are given)\n"
  printf "\t--availability-zone\tAZ (defaults to '%s', used if neither --instance-id nor --host are given)\n" "${az}"
  printf "\t--ami-id\t\tAMI ID (defaults to latest ubuntu-xenial-16.04, used if neither --instance-id nor --host are given)\n"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --instance-id) instance_id="$2"; shift;;
  --instance-id=*) instance_id="${1#*=}";;

  --instance-type) instance_type="$2"; shift;;
  --instance-type=*) instance_type="${1#*=}";;

  --subnet-id) subnet_id="$2"; shift;;
  --subnet-id=*) subnet_id="${1#*=}";;

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

  --rsync) rsync="yes";;

  --prepare-test) prepare_test="yes";;

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
  echo "ERROR: --keypair is required."
  exit 1
fi
keyfile="${keypair}.pem"
if [ ! -f "$keyfile" ]; then
  echo "ERROR: Keypair file $keyfile does not exist."
  exit 1
fi

if [ -z "${host}" ]; then
  if [ -z "${instance_id}" ]; then
    if [ -z "${subnet_id}" ]; then
      echo "ERROR: --subnet-id not given."
      exit 1
    fi
    if [ -z "${security_group_id}" ]; then
      echo "ERROR: --security-group-id not given."
      exit 1
    fi
    if [ -z "${keypair}" ]; then
      echo "ERROR: --key-name not given."
      exit 1
    fi
    if [ -z "${ami_id}" ]; then
      ami_id=$(aws ec2 describe-images \
        --owners 099720109477 \
        --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64*" "Name=root-device-type,Values=ebs" \
        --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')
    fi
    echo "Launching temporary instance (${instance_type}) with AMI=${ami_id} in AZ/subnet=${az}/${subnet_id} with security_group=${security_group_id} ..."
    echo "Boot instance"
    instance_id=$(aws ec2 run-instances --image-id $ami_id \
    --count 1 \
    --instance-type ${instance_type} \
    --key-name ${keypair} \
    --security-group-ids $security_group_id \
    --block-device-mappings "[{ \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": ${volume_size} } }]" \
    --subnet-id ${subnet_id} | jq -r '.Instances[0].InstanceId')
    echo "Created instance with ID=${instance_id}, waiting for it to be running ..."
    aws ec2 wait instance-running --instance-ids $instance_id
    echo "Instance with ID=${instance_id} running"
    aws ec2 create-tags --resources ${instance_id} --tags Key=Name,Value=ODS-Test

    prepare_test="yes"
    wait="yes"
  fi

  echo "Get IP address"
  host=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
  echo "Instance has address=${host}"
fi

if [ -n "${wait}" ]; then
  echo "Wait for 30 seconds"
  sleep 30
fi

if [ -n "${rsync}" ]; then
  echo "Using rsync to upload local folder to AWS"
  cd ${SCRIPT_DIR}/..
  rsync --rsh "ssh ${strictHostKeyChecking} -i ${SCRIPT_DIR}/$keyfile" -v \
    --exclude .git/ --exclude docs/ --exclude infrastructure-setup/ --exclude "*.pem" \
    --update --delete --archive . ubuntu@$host:/home/ubuntu/ods-core
  cd -
fi

if [ -n "${prepare_test}" ]; then
  echo "Preparing tests in EC2 instance"
  if [ -z "${rsync}" ]; then
    scp -i $keyfile install.sh ubuntu@$host:/home/ubuntu/install.sh
    ssh ${strictHostKeyChecking} -i $keyfile ubuntu@$host -- "./install.sh"
  else
    ssh ${strictHostKeyChecking} -i $keyfile ubuntu@$host -- "ods-core/tests/install.sh"
  fi

  ssh ${strictHostKeyChecking} -i $keyfile ubuntu@$host -- "source /etc/profile; ods-core/tests/prepare-test.sh"
fi

echo "Running tests in EC2 instance"
ssh ${strictHostKeyChecking} -i $keyfile ubuntu@$host -- "source /etc/profile; ods-core/tests/test.sh"
echo "Done"
