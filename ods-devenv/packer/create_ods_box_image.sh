#!/usr/bin/env bash

aws_access_key=
aws_secret_key=
ods_branch=

s3_bucket_name=
s3_upload_folder=image_upload
artefact_folder=output-vmware-iso

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --ods-branch) ods_branch="$2"; shift;;
  --ods-branch=*) ods_branch="${1#*=}";;

  --s3_bucket_name) s3_bucket_name="$2"; shift;;
  --s3_bucket_name=*) s3_bucket_name="${1#*=}";;

  --s3-upload-folder) s3_upload_folder="$2"; shift;;
  --s3-upload-folder=*) s3_upload_folder="${1#*=}";;

  --target) target="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

function display_usage() {
    echo TODO
}

#######################################
# creates a local CentOS image capable of running an ODS box
# Globals:
#   centos_iso_location e.g. file:///tmp/centos.si
#######################################
function create_local_centos_image() {
    time packer build -on-error=ask \
        -var "centos_iso_location=centos_iso_location" \
        -var ssh_username=openshift \
        -var ssh_password=openshift \
        ods-devenv/packer/CentOS_BaseImage_VMWare.json
}

#######################################
# uploads a vmdk to AWS EC2 AMI
# Globals:
#   s3_bucket_name
#   s3_upload_folder
#   artefact_folder
#######################################
function upload_local_centos_image() {
    # rm artefacts from last upload
    if aws s3 ls "s3://${s3_bucket_name}" | grep -q "${s3_upload_folder}"
    then
        aws s3 rm "s3://${s3_bucket_name}/${s3_upload_folder}" --recursive
    fi
    aws s3 cp "${artefact_folder}/disk.vmdk" "s3://${s3_bucket_name}/${s3_upload_folder}/"
}

#######################################
# creates an ODS box image for AWS EC2
# Globals:
#   aws_access_key
#   aws_secret_key
#   ods_branch
#######################################
function create_ods_box_ami() {
    time packer build -on-error=ask \
        -var "aws_access_key=${aws_access_key}" \
        -var "aws_secret_key=${aws_secret_key}" \
        -var 'username=openshift' \
        -var 'password=openshift' \
        -var "name_tag=ODS Box $(date)" \
        -var "ods_branch=${ods_branch}" \
        ods-devenv/packer/CentOS2ODSBox.json
}

# creates a local ODS box image for VMware
function create_ods_box_vmdk() {
    # implement if ever used ...
    :
}

target="${target:-display_usage}"
${target}
