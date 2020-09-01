# Sample packer command
To build an ODS box AMI for AWS EC2 using the provided packer templates, use a packer command like specified below. Note: you may have to specify directories as used in the statements and configure the packer run in .packerrc.
```
export PACKER_LOG=1 && \
    export AWS_MAX_ATTEMPTS=400 && \
    export AWS_POLL_DELAY_SECONDS=15 && \
    source ods-devenv/packer/.packerrc && date && \
    mkdir -p "${log_path}" && \
    log_file="${log_path}/build_$(echo "${branch}" | tr "/" "_")_$(date +%Y%m%dT%H%M%S).log" && \
    ln -s "${log_path}/current" "${log_file}" && \
    time bash 2>&1 ods-devenv/packer/create_ods_box_image.sh \
        --target create_ods_box_ami \
        --aws-access-key "${aws_access_key}" \
        --aws-secret-key "${aws_secret_access_key}" \
        --ods-branch "${branch}" \
        --instance-type ${instance_type} \
    | tee "${log_file}"'
```
PACKER_LOG: Make packer's log behavior more verbose for improved error handling and debugging.

AWS_MAX_ATTEMPTS: The resulting AMI size for ODS in a box images is about 100GB which results in longer processing times on AWS side. To avoid timeouts in packer, increase values for AWS_MAX_ATTEMPTS and AWS_POLL_DELAY_SECONDS

AWS_POLL_DELAY_SECONDS: The resulting AMI size for ODS in a box images is about 100GB which results in longer processing times on AWS side. To avoid timeouts in packer, increase values for AWS_MAX_ATTEMPTS and AWS_POLL_DELAY_SECONDS
