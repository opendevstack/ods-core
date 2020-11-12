#!/usr/bin/env bash

function help() {
    echo
}


# The EC2 instance will be created from the community CentOS AMI ami-0d4002a13019b7703
# Community CentOS 7.8.2003 x86_64 AMI available in eu-west-1 using 8GB partition
# username: centos
amiId=ami-0d4002a13019b7703

# sensible machine sizes:
# t2.large -> 2 vCPUs, 8 GiB
# t2.xlarge -> 4 vCPUs, 16 GiB
instanceType=t2.large

# the AWS keyname must be configured when the script is called.
# this will tell AWS EC2 which public key to paste into ~/.ssh/authorized_keys 
keyName=

# size of the EBS disk. For the default AMI the size is 8GB.
volumeSize=8

# security group to be applied to the buildbot host. the id has to be specified.
securityGroupId=

function resolveArgs() {
    while [[ "$#" -gt 0 ]]
    do
        case $1 in
            -v|--verbose) set -x;;

            -h|--help) usage; exit 0;;

            --ami-id) amiId="$2"; shift;;

            --instance-type) instanceType="$2"; shift;;

            -k|--key-name) keyName="$2"; shift;;

            --volume-size) volumeSize="$2"; shift;;

            -s|--security-group-id) securityGroupId="$2"; shift;;

            *) echo "Unknown parameter passed: $1"; exit 1;;

        esac
        shift
    done

    local missingArgs
    if [[ -z "${keyName}" ]]
    then
        missingArgs="${missingArgs} --key-name"
    fi
    if [[ -z "${securityGroupId}" ]]
    then
        missingArgs="${missingArgs} --security-group-id"
    fi
    if [[ -n "${missingArgs}" ]]
    then
        # apply whitespace trimming to missingArgs
        missingArgs=$(echo "${missingArgs}" | xargs)
        echo "The following arguments need to be specified: ${missingArgs// /, }"
        exit 1
    fi
}

function usage() {
    echo "NAME"
    echo "    deployBuildbot.sh -- create a new EC2 instance and deploy a runnable version"
    echo "    of the ODS Box AMI buildbot"
    echo "SYNOPSIS"
    echo "DESCRIPTION"
    echo "    this script will start a new EC2 instance in the AWS account for"
    echo "    the access_key / secret_access_key as configured in the local aws cli installation,"
    echo "    and install the ODS Box AMI buildbot on that EC2 instance."
    echo
    echo "    the buildbot host will run"
    echo "        - nginx for serving files and reverse proxy for github app"
    echo "        - multiple simultaneous packer AMI builds"
    echo "OPTIONS"
    echo "    required arguments"
    echo "    -k, --key-name"
    echo "        Name of the public key with AWS EC2 which shall be pasted to ~/.ssh/authorized_keys for"
    echo "        authentication when logging into the buildbot box."
    echo "    -s, --security-group-id"
    echo "        The id of the AWS EC2 security-group that shall be applied to the buildbot EC2 host."
    echo "        The security group must have incoming traffic on 22, 80, 443 enabled."
    echo
    echo "    optional arguments"
    echo "    --ami-id"
    echo "        id of the AMI used to create the buildbot host EC2 instance."
    echo "        Since the ODS Box itself is hosted on CentOS 7.8.2003 the buildbot will be hosted on"
    echo "        the same OS per default."
    echo "    -h, --help"
    echo "        Print this help."
    echo "    --instance-type"
    echo "        The EC2 instance type. Sensible values would be t2.large or t2.xlarge."
    echo "    -v, --verbose"
    echo "        List every command executed before executing it."
    echo "    --volume-size"
    echo "        Specify the disk size for the buildbot EC2 instance. Should be the value"
    echo "        as defined by the AMI in use."
}

function deployBuildbot() {
    local instanceId
    instanceId=$(aws ec2 run-instances --image-id "${amiId}" \
       --count 1 \
       --instance-type "${instanceType}" \
       --key-name "${keyName}" \
       --block-device-mappings "[{ \"DeviceName\": \"/dev/sda1\", \"Ebs\": { \"VolumeSize\": ${volumeSize} } }]" \
       | jq -r '.Instances[0].InstanceId' )
    echo "Created buildbot host EC2 instance with instance-id ${instanceId}, waiting for it to be running ..."
    aws ec2 wait instance-running --instance-ids "${instanceId}"
    echo "... buildbot host EC2 instance ${instanceId} is running."
    buildbotInstanceName="ODS buildbot host $(date '+%Y-%m-%d %H:%M:%S')"
    aws ec2 create-tags --resources "${instanceId}" --tags "Key=Name,Value=${buildbotInstanceName}"

    waitOnBuildbotEC2InstanceToBecomeAvailable "${instanceId}"

    local publicIP
    publicIP=$(aws ec2 describe-instances --instance-ids "$instanceId" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
    echo "buildbot EC2 host has the public IP address ${publicIP}"

    local publicDNS
    publicDNS=$(aws ec2 describe-instances --instance-ids "${instanceId}" --query 'Reservations[].Instances[].PublicDnsName' --output text)
    echo "buildbot EC2 host has the public DNS ${publicDNS}."

    setupBuildBot "${publicIP}"

}

function setupBuildbot() {
    local publicIP="$1"

    echo "Setting up buildbot at IP ${publicIP}"
}

function waitOnBuildbotEC2InstanceToBecomeAvailable() {
    local instanceId="$1"
    local instanceState

    echo -n "Waiting for ODS Box instance ${instanceId} to become available."
    instanceState=$(aws ec2 describe-instance-status --instance-ids  "${instanceId}" | jq ".InstanceStatuses[].SystemStatus.Details[].Status")
    while [[ ${instanceState} != \"passed\" ]]
    do
        echo -n "."
        sleep 5
        instanceState=$(aws ec2 describe-instance-status --instance-ids  "${instanceId}" | jq ".InstanceStatuses[].SystemStatus.Details[].Status")
    done
    echo "available."
}

resolveArgs "$@"
deployBuildbot
