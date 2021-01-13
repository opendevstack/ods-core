#!/usr/bin/env bash

aws_access_key=
aws_secret_key=

# default public key to be added to the odsbox authorized_keys
pub_key=ods-devenv/packer/odsbox.pub

ods_branch=master

s3_bucket_name=
s3_upload_folder=image_upload
output_directory=output-vmware-iso
instance_type=m5ad.4xlarge

dryrun=false

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

    --instance-type) instance_type="$2"; shift;;
    --instance-type=*) instance_type="${1#*=}";;

    --output-directory) output_directory="$2"; shift;;
    --output-directory=*) output_directory="${1#*=}";;

    --pub-key) pub_key="$2"; shift;;
    --pub-key=*) pub_key="${1#*=}";;

    --target) target="$2"; shift;;

    --dryrun) dryrun=true;;

    --help) target=display_usage;;

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
    echo "                      E.g. myimages"
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
    echo "  Requires the cli tool ovftool - shipping with VMware - to be on the PATH"
    echo "      --s3-bucket-name        name of your AWS S3 bucket to upload the image to"
    echo "      --output-directory      folder where the disk.vmdk file of the CentOS VM gets written"
    echo "                              defaults to output-vmware-iso, as created by packer"
    echo
    echo "  create_ods_box_ami"
    echo "  Build an ODS Box AMI based on the previously uploaded CentOS box on AWS"
    echo "      --aws-access-key        AWS credentials"
    echo "      --aws-secret-key        AWS credentials"
    echo "      --pub-key               Public key to be added to the odsbox authorized servers"
    echo "      --ods-branch            branch to build ODS box against, e.g master"
    echo "      --instance-type         AWS EC2 instance type to run the AMI build on. Defaults to m5ad.4xlarge."
    echo "                              Options: t2.2xlarge, m5ad.4xlarge"
    echo "      --dry-run               only query for ami-id, log parameters, wait a bit, and then exit without"
    echo "                              actually calling packer"
    echo
}

#######################################
# creates a local CentOS image capable of running an ODS box
# Globals:
#   centos_iso_location e.g. file:///tmp/centos.si
#######################################
function create_local_centos_image() {
    if [[ -d "${output_directory}" ]]
    then
        echo "packer output_directory ${output_directory} already exists, which is inacceptable for packer!"
        echo "Please resolve this issue and then restart the script."
        exit 1
    fi
    # if you want to change login username and password below, you have to sync the changes
    # with the user data specified in the CentOS kickstart.cfg file
    time packer build -on-error=ask \
        -var "centos_iso_location=${centos_iso_location}" \
        -var ssh_username=openshift \
        -var ssh_password=openshift \
        ods-devenv/packer/CentOS_BaseImage_VMWare.json
}

#######################################
# uploads an ova file to AWS S3 and has it converted to an AWS EC2 AMI
# Globals:
#   s3_bucket_name
#   s3_upload_folder
#   output_directory
#######################################
function import_centos_image_to_aws() {
    local upload_path
    upload_path="${s3_upload_folder%/*}/$(date '+%Y%m%d')"
    echo "Uploading local CentOS 7.8 image to AWS S3 bucket s3://${s3_bucket_name}/${upload_path} and importing it as AMI"
    # rm artefacts from last upload
    if [[ -n "$(aws s3 ls "s3://${s3_bucket_name}/${upload_path}")" ]]
    then
        echo "Upload folder ${upload_path} already found on S3 bucket ${s3_bucket_name}. Cleaning it up before upload ..."
        aws s3 rm "s3://${s3_bucket_name}/${s3_upload_folder}" --recursive
    fi

    pushd "${output_directory}" || return
    echo "Exporting VMware vmx to ova"
    ovftool --acceptAllEulas packer-vmware-iso.vmx centosbox.ova
    popd || return

    echo "Uploading exported ova to AWS S3: s3://${s3_bucket_name}/${upload_path}/centosbox.ova"
    aws s3 cp "${output_directory}/centosbox.ova" "s3://${s3_bucket_name}/${upload_path}/centosbox.ova"

    local jq_query
    jq_query=$(cat <<- EOF
        .[0].Description = "CentOS base image $(date '+%Y%m%d %H%M')" |
        .[0].Format = "ova" |
        .[0].UserBucket.S3Bucket = "${s3_bucket_name}" |
        .[0].UserBucket.S3Key = "${s3_upload_folder}/$(date '+%Y%m%d')/centosbox.ova"
EOF
    )
    echo "built jq query string to build containers.json file: ${jq_query}"

    local absolute_path2here
    absolute_path2here="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
    # prepare containers.json for AWS AMI image import
    jq "${jq_query}" "${absolute_path2here}/containers.template" > "${absolute_path2here}/containers.json"
    echo "Created containers.json"
    jq . < "${absolute_path2here}/containers.json"
    echo "Importing CentOS image to AMI"
    local import_task_id
    import_task_id=$(aws ec2 import-image --description "My server VM" --disk-containers "file:///${absolute_path2here}/containers.json" | jq -r ".ImportTaskId")
    echo -n "Waiting for CentOS AMI for import task ID ${import_task_id} to become available."
    while ! aws ec2 describe-import-image-tasks --import-task-ids "${import_task_id}" | jq -r ".ImportImageTasks[0].Status" | grep -iq completed
    do
        echo -n '.'
        sleep 20
    done
    echo "is available."
    echo "Cleaning up containers.json"
    rm -v "${absolute_path2here}/containers.json"
}

#######################################
# creates an ODS box image for AWS EC2
# Globals:
#   aws_access_key
#   aws_secret_key
#   ods_branch
#   instance_type
#######################################
function create_ods_box_ami() {
    local ami_id
    ami_id=$(aws ec2 describe-images \
                --owners 275438041116 \
                --filters "Name=name,Values=import-ami-*" "Name=root-device-type,Values=ebs" "Name=tag:Name,Values=CentOS*" \
                --query 'Images[*].{ImageId:ImageId,CreationDate:CreationDate}' | jq -r '. |= sort_by(.CreationDate) | reverse[0] | .ImageId')

    echo "ami-id=${ami_id}"
    echo "PACKER_LOG=${PACKER_LOG}"
    echo "AWS_MAX_ATTEMPTS=${AWS_MAX_ATTEMPTS}"
    echo "AWS_POLL_DELAY_SECONDS=${AWS_POLL_DELAY_SECONDS}"
    echo "ods_branch=${ods_branch}"

    if [[ "${dryrun}" == "true" ]]
    then
        echo -n "dryrun"
        local counter=0
        while (( counter <= 10 ))
        do
            sleep 1
            counter=$((counter + 1))
            echo -n '.'
        done
        echo "done."
        exit 0
    else
        time packer build -on-error=ask \
            -var "aws_access_key=${aws_access_key}" \
            -var "aws_secret_key=${aws_secret_key}" \
            -var "ami_id=${ami_id}" \
            -var 'username=openshift' \
            -var 'password=openshift' \
            -var "name_tag=ODS Box $(date)" \
            -var "ods_branch=${ods_branch}" \
            -var "instance_type=${instance_type}" \
            -var "pub_key=${pub_key}" \
            ods-devenv/packer/CentOS2ODSBox.json
    fi
}

target="${target:-display_usage}"
${target}
