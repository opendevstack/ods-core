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

  --s3-bucket-name) s3_bucket_name="$2"; shift;;
  --s3-bucket-name=*) s3_bucket_name="${1#*=}";;

  --s3-upload-folder) s3_upload_folder="$2"; shift;;
  --s3-upload-folder=*) s3_upload_folder="${1#*=}";;

  --centos-iso-location) centos_iso_location="$2"; shift;;
  --centos-iso-location=*) centos_iso_location="${1#*=}";;

  --aws-access-key) aws_access_key="$2"; shift;;
  --aws-access-key=*) aws_access_key="${1#*=}";;

  --aws-secret-key) aws_secret_key="$2"; shift;;
  --aws-secret-key=*) aws_secret_key="${1#*=}";;

  --target) target="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

function display_usage() {
    echo "This script provides functionality to create and distribute images for the ODS box,"
    echo "like the CentOS 7.8 2003 base image and the ODS box image."
    echo
    echo "The script can be parameterized depending on the use case."
    echo "--ods-branch          The ods branch to build the ODS box from, e.g. master or feature/ods-devenv"
    echo
    echo "--s3-bucket-name      For use cases where there is an AWS S3 bucket involved, specify your bucket here."
    echo "                      E.g. when importing a new local VMware image into an AWS ECS AMI."
    echo "--s3-upload-folder    Specify a folder within your S3 bucket to upload local image files to."
    echo "                      If it does not exist yet, the folder will be created upon upload."
    echo
    echo "Target Section        lists the use cases that can be executed and their parameters."
    echo "--target              Specify the use case you want to execute. E.g. create_local_centos_image"
    echo
    echo "  create_local_centos_image"
    echo "  Build a CentOS 7.8 2003 base image locally using VMware infrastructure"
    echo "      --centos-iso-location   absolute path to the CentOS installer iso file in the format"
    echo "                              file:///absolute_path/CentOS-7-x86_64-DVD-2003.iso"
    echo
    echo "  import_centos_image_to_aws"
    echo "  Upload a locally available vmdk or other image file to AWS EC2 for later import to AMI."
    echo "      --s3-bucket-name        name of your AWS S3 bucket to upload the image to"
    echo "      --artefact-folder       folder where the disk.vmdk file of the CentOS VM resides"
    echo "                              defaults to output-vmware-iso, as created by packer"
    echo
    echo "  create_ods_box_ami"
    echo "  Build an ODS Box AMI based on the previously uploaded CentOS box on AWS"
    echo "      --aws-access-key        AWS credentials"
    echo "      --aws-secret-key        AWS credentials"
    echo "      --ods_branch            branch to build ODS box against, e.g master"
    echo
}

#######################################
# creates a local CentOS image capable of running an ODS box
# Globals:
#   centos_iso_location e.g. file:///tmp/centos.si
#######################################
function create_local_centos_image() {
    # if you want to change login username and password below, you have to sync the changes
    # with the user data specified in the CentOS kickstart.cfg file
    time packer build -on-error=ask \
        -var "centos_iso_location=${centos_iso_location}" \
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
function import_centos_image_to_aws() {
    echo "Uploading local image to AWS S3 and importing it as AMI"
    # rm artefacts from last upload
    if aws s3 ls "s3://${s3_bucket_name}" | grep -q "${s3_upload_folder}"
    then
        aws s3 rm "s3://${s3_bucket_name}/${s3_upload_folder}" --recursive
    fi
    aws s3 cp "${artefact_folder}/disk.vmdk" "s3://${s3_bucket_name}/${s3_upload_folder}/"

    local jq_query
    jq_query=$(cat <<- EOF
        .[0].Description = "CentOS base image $(date '+%Y%m%d %H%M')" |
        .[0].Format = "vmdk" |
        .[0].UserBucket.S3Bucket = "${s3_bucket_name}" |
        .[0].UserBucket.S3Key = "${s3_upload_folder}/$(date '+%Y%m%d')/disk.vmdk"
EOF
    )
    echo "built jq query string to build containers.json file: ${jq_query}"

    local absolute_path2here
    absolute_path2here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    # prepare containers.json for AWS AMI image import
    jq "${jq_query}" "${absolute_path2here}/containers.template" > "${absolute_path2here}/containers.json"
    echo "Created containers.json"
    jq . < "${absolute_path2here}/containers.json"
    echo "Importing CentOS image to AMI ..."
    aws ec2 import-image --description "My server VM" --disk-containers "file:///${absolute_path2here}/containers.json"
    echo "Clenaing up containers.json"
    rm -v "${absolute_path2here}/containers.json"
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

target="${target:-display_usage}"
${target}
