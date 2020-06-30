# EDP / ODS box

## Quickstart
### Provision an ODS box on AWS
The script ods-core/ods-devenv/scripts/run-on-aws.sh can be used to quickly and conveniently provision a new ODS box EC2 instance on AWS. There are several options to choose from to support the most frequent use cases:
```
# to startup a vanilla ODS box from a pre-built ODS Box master AMI, using default ODS AMI and security group in a public facing VPC
# startup time about 5 minutes
./run-on-aws.sh

# to startup an ODS box from a pre-built ODS Box for the given branch, otherwise like above
./run-on-aws.sh --target-git-ref feature/ods-devenv

# to startup from a specific ODS AMI, also using a specific security group
./run-on-aws.sh --ami-id i-############ --security-group-id sg-006935bec03a154a1

# to setup a bleeding edge ODS box from current master
# startup time about 45 minutes
./run-on-aws.sh --install

# To setup and start a fresh ODS in a box instance from a specific branch
# startup time about 45 minutes
# note: the given branch must exist on ods-core, ods-jenkins-shared-library and ods-quickstarters
./run-on-aws.sh --install --target-git-ref my-branch-name

# To deploy the ODS box in a specific VPC, specifiy the corresponding subnet
# To connect to the machine, port forwarding using the AWS SSM Agent may be required
./run-on-aws.sh --iam-instance-profile arn:aws:iam::############:instance-profile/AmazonSSMManagedInstanceCore-profilename --subnet-id subnet-#################

# To stop an ODS box, e.g. for the weekend, run this sequence of commands from the ODS box terminal
stop_ods
sudo shutdown -h now

# To restart ODS services on a rebooted ODS box, run this command from the ODS box terminal
startup_ods

# When using Atlassian timebomb licenses: to reset the 3 hours validity window of the Atlassian suite's timebomb licenses run this command from the ODS box terminal
restart_atlassian_suite

# Using packer to build ODS Box AMI on AWS
time packer build -on-error=ask -var 'aws_access_key=#####' -var 'aws_secret_key=#####' -var 'username=openshift' -var 'password=openshift' -var "name_tag=ODS Box $(date)" -var 'ods_branch=feature/ods-devenv' ods-devenv/packer/CentOS2ODSBox.json

# Using packer to build CentOS base image locally on VMWare (Fusion)
packer build -on-error=ask -var centos_iso_location=file:///path_to_folder/CentOS-7-x86_64-DVD-2003.iso -var ssh_username=openshift -var ssh_password=openshift ./ods-devenv/packer/CentOS_BaseImage_VMWare.json
```

## Connecting to the ODS box
### via RDP / SSH
If the ODS box is deployed in a public facing VPC, then direct access via SSH and RDP is possible. The correspoding ssh and rdp services are running on the ODS box per default.

After having started the ODS box using run-on-aws.sh retrieve the public DNS from the AWS console and run
E.g.
```
    ssh openshift@public_dns
```
Or configure the RDP client with the public DNS to connect to the ODS box.

Note: in the default configuration, run-on-aws.sh will configure a security group that allows access to ports 22 and 3389. If a different security group or a more restrictive VPC is used, this simple and insecure approach will most probably not work any more and different means are required. E.g. see AWS SSM below.
### via AWS SSM
All ODS box instances derived from the custom ODS CentOS 7.8 2003 base image come with the AWS Systems Manager Agent pre-installed. AWS SSM can be used to do port forwarding from the local workstation to the ODS box on AWS EC2. RDP or ssh sessions can be tunneled through that way.

Prerequisites:
-   Access to the AWS account hosting the EC2 instance
-   Locally install the AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
-   Locally install the Session Manager Plugin for the AWS CLI -
https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
-   Retrieve an access key from AWS IAM - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html - and configure the AWS CLI

When the ODS box is deployed in the correct VPC / subnet, an SSH tunnel can be established like so:
```
# Run the following commands to verify that the Session Manager plugin installed successfully on your local machine:
session-manager-plugin
# The following message should be returned:
# The Session Manager plugin is installed successfully. Use the AWS CLI to start a session.

# sample code for establishing an SSH tunnel to ssh into an ODS box, where
#   --target the instance-id of the EC2 instance running the ODS box
#   --document-name reference to a document containins specificas about the required session
#   --parameters port numbers for the port forwarding
aws ssm start-session \
--target i-0306756a7e96f8e24 \
--document-name AWS-StartPortForwardingSession \
--parameters '{"portNumber":["22"], "localPortNumber":["22"]}'

# Check whether the Amazon SSM agent is running on the ODS box
sudo systemctl status amazon-ssm-agent
```

# Resources
## AMI - machine images
This project provides images from which ODS boxes can be derived or instantiated.
- ami-0169ff0d4d60f016b - a CentOS 7.8 2003 base image. Running the script ods-core/ods-devenv/scripts/bootstrap.sh on this box will yield a fresh ODS box built from master / configurable branch.
- ami-058369867e8b7aa74 - this image contains a complete ODS setup and only needs to be started up, e.g. using by running ```bash ods-devenv/scripts/deploy.sh --target startup_ods``` from the ods-core folder.

## Scripts
### bootstrap.sh
Can be used to convert a CentOS 7.8 2003 box into an ODS box.
### deploy.sh
Contains a bunch of targets that can be called single file or by running bootstrap.sh to configure a CentOS 7.8 2003 box towards an ODS box.

The functions can be called like this:
```
# basic_vm_setup is a utility function that will
# call other functions to perform the complete
# EDP/ODS setup.
bash deploy.sh --target basic_vm_setup --branch master

# will install the docker infrastructure
bash deploy.sh install_docker

# will install remote desktop infrastructure
bash deploy.sh setup_rdp
```
The following components will be installed
- OpenShift 3.11
    - Credentials: developer:(any password strategy) means: you can enter any password you like
    - ODS
        - Provisioning app
            - Credentials: openshift:openshift
        - Nexus
            - Credentials: admin:openshift
        - Jenkins
            - OpenShift credentials
        - SonarQube
            - Credentials: openshift:openshift
- Atlassian Stack
    - Jira 8.3.5
        - 3H Atlassian timebomb licenses (https://developer.atlassian.com/platform/marketplace/timebomb-licenses-for-testing-server-apps/)
        - Credentials: openshift:openshift
    - BitBucket
        - 3H Atlassian timebomb licenses
        - Credentials: openshift:openshift
    - Crowd
        - 3H Atlassian timebomb licenses
        - Credentials: openshift:openshift
    - MySQL DB for the Atlassian Suite
        - credentials: root:jiradbrpwd
- Tailor 1.1.2

## Installation Instructions
### Local Deployment
For local deployment create a VMWare (recommended) or VirtualBox virtual machine from CentOS-7.8 2003 using this configuration:

### VMWAre Machine Configuration
- VMWare Machine Configuration
    - At least 4 processor cores. The setup has also been tested with 2 cores but the usability is very limited in this configuration
    - At least 16 GB RAM. The basic setup running OpenShift, Atlassian BitBucket, Atlassian Jira, Sonatype Nexus, SonarQube, Jenkins and a Webhook Proxy will require 16 GB of RAM. Deploying additional applications and running pipelines will require additional memory.
    - enable hypervisor applications
    - 70 GB harddisk (40GB proved to be too little space for a whole installation)
    - Connect network adapter
        - Configure Bridged Networking (Autodetect)
- CentOS setup
    - Timezone CEST
    - Server with GUI (Gnome)
    - Create admin user openshift
        - Make user admin -> add user to wheel group to allow it to use sudo.
        - Add user to docker group. Failing to do so will prevent OpenShift installation from working.
    - Set root user password
    - Update the system (yum update)
- Desktop Configuration
    - Install Amazon SSM Agent
        - https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-centos.html
        - https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html
    - Enable RDP
    - Turn off screen-lock
    - The following steps need to be executed as openshift user
        - ```cd ${HOME}```
        - ```mkdir -p bin```
        - ```vim bin/bootstrap```
        - copy and paste the contents of the script ods-core/ods-devenv-scripts/bootstrap.sh
        - ```chmod u+x bin/bootstrap```
        - ```bootstrap```
        - The bootstrap script will clone the ods-core project from github and run the ods-devenv setup script
        - Software
          - Google Chrome
          - Visual Studio Code
    - Provide shortcuts for
      - OpenShift Webconsole
      - BitBucket
      - Jira
      - System Tools
      - Chrome
      - Terminal
