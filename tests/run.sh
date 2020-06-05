#!/bin/bash
set -eu
set -o pipefail

instance_type="t2.micro"
key="private-key.pem"
az="eu-west-1a"
ami_id=""
host=""
subnet_id=""
key_name=""
instance_id=""
security_group_id=""

function usage {
  printf "Run tests in AWS.\n\n"
  printf "Usage:\n\n"
  printf "\t--help\t\tPrint usage\n"
  printf "\t--verbose\t\tEnable verbose mode\n"
  printf "\t--host\t\tHost (bypasses launching a new instance)\n"
  printf "\t--instance-id\t\tInstance ID\n"
  printf "\t--instance-type\t\tInstance Type(defaults to '%s')\n" "${az}"
  printf "\t--subnet-id\t\tSubnet ID (required if neither --instance-id nor --host are given)\n"
  printf "\t--security-group-id\t\tSecurity Group (required if neither --instance-id nor --host are given)\n"
  printf "\t--private-key\t\tPrivate key (*.pem)\n"
  printf "\t--key-name\t\tName of keypair (required if neither --instance-id nor --host are given)\n"
  printf "\t--availability-zone\t\tAZ (defaults to '%s')\n" "${az}"
  printf "\t--ami-id\t\tAMI ID (required if neither --instance-id nor --host are given)\n"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --verbose) set -x;;

  --help) usage; exit 0;;

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

  --private-key) key="$2"; shift;;
  --private-key=*) key="${1#*=}";;

  --key-name) key_name="$2"; shift;;
  --key-name=*) key_name="${1#*=}";;

  --availibility-zone) az="$2"; shift;;
  --availibility-zone=*) az="${1#*=}";;

  --ami-id) ami_id="$2"; shift;;
  --ami-id=*) ami_id="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! which aws &> /dev/null; then
  echo "ERROR: Install aws-cli: https://docs.aws.amazon.com/de_de/cli/latest/userguide/cli-chap-install.html"
  exit 1
fi

if ! which jq &> /dev/null; then
  echo "ERROR: Install jq: https://stedolan.github.io/jq/download/"
  exit 1
fi

if [ ! -f "$key" ]; then
  echo "ERROR: Keypair file $key does not exist."
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
    if [ -z "${key_name}" ]; then
      echo "ERROR: --key-name not given."
      exit 1
    fi
    echo "Launching temporary instance (${instance_type}) with AMI=${ami_id} in AZ/subnet=${az}/${subnet_id} with security_group=${security_group_id} ..."
    echo "Boot instance"
    instance_id=$(aws ec2 run-instances --image-id $ami_id \
    --count 1 \
    --instance-type ${instance_type} \
    --key-name ${key_name} \
    --security-group-ids $security_group_id \
    --subnet-id ${subnet_id} | jq -r '.Instances[0].InstanceId')
    echo "Created instance with ID=${instance_id}, waiting for it to be running ..."
    aws ec2 wait instance-running --instance-ids $instance_id
    echo "Instance with ID=${instance_id} running"
  fi

  echo "Get IP address"
  host=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
  echo "Instance has address=${host}"
fi

echo "SSH into instance and run tests"
scp -i $key test.sh ubuntu@$host:/home/ubuntu/test.sh
ssh -i $key ubuntu@$host 'bash -c "./test.sh"'
echo "Done"
