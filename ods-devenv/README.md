# EDP / ODS Development Environment
This project provides scripts to setup a development environment for EDP/ODS, aka EDP in a box.

The EDP box is intended to run in various environments:
- As an EC2 virtual machine on AWS
- Locally as a virtual machine powered by
  - VMWare or
  - VirtualBox

The core script is ods-core/ods-devenv/scripts/deploy.sh. It is intended to be run by an unprivileged user on the target system (see installation instructions below).
The script implements a set of functions that can be executed en-suite or single file as needed.

The functions can be called like this:
```
bash deploy.sh basic_vm_setup       # basic_vm_setup is a utility function that will
                                    # call other functions to perform the complete
                                    # EDP/ODS setup.
bash deploy.sh install_docker       # will install the docker infrastructure
bash deploy.sh setup_rdp            # will install remote desktop infrastructure
```

Currently, the script will setup a fresh VM with an OpenShift cluster, a docker installation and some means of communication with clients.
Next steps will be
- Install ODS in OpenShift
- Integrate provisioning-app

The following components will b installed
- OpenShift 3.11
    - Sonatype Nexus
    - SonarQube
- Atlassian Stack
    - Jira 8.3.5
        - 3H Atlassian timebomb licenses (https://developer.atlassian.com/platform/marketplace/timebomb-licenses-for-testing-server-apps/)
        - Credentials: openshift:openshift
    - BitBucket
        - 3H Atlassian timebomb licenses
        - Credentials: openshift:openshift
    - MySQL DB for the Atlassian Suite
    - credentials: root:jiradbrpwd

## Installation Instructions
### Local Deployment
For local deployment create a VMWare (recommended) or VirtualBox virtual machine from CentOS-7.8 2003 using this configuration:
(note: these steps will be automated using Packer)

All of the prerequisites listed below are essentials for the setup to work. E.g. failing to add the Linux user to the groups docker and wheel will prevent the setup script from working.

- VMWare Machine Configuration
    - At least 4 processor cores. The setup has also been tested with 2 cores but the usability is very limited in this configuration
    - At least 12 GB RAM. The basic setup running OpenShift, Atlassian BitBucket, Atlassian Jira, Sonatype Nexus, SonarQube, Jenkins and a Webhook Proxy will require 12 GB of RAM. Deploying additional applications and running pipelines will require additional memory.
    - enable hypervisor applications
    - 40 GB harddisk
    - Connect network adapter
        - Configure Bridged Networking (Autodetect)
- CentOS setup
    - Timezone CEST
    - Server with GUI (Gnome)
    - create admin user openshift
        - Make user admin -> add user to wheel group to allow it to use sudo.
        - Add user to docker group. Failing to do so will prevent OpenShift installation from working.
    - set root user password
- Desktop Configuration
    - The following steps need to be executed as openshift user
        - ```cd ${HOME}```
        - ```mkdir -p bin```
        - ```vim bin/bootstrap```
        - copy and paste the contents of the script ods-core/ods-devenv-scripts/bootstrap.sh
        - ```chmod u+x bin/bootstrap```
        - ```bootstrap```
        - The bootstrap script will clone the ods-core project from github and run the ods-devenv setup script

### AWS deployment
Use the provided AWS AMI to launch an instance of the ODS development environment
(note: these steps will be automated using Packer)
- Login to the AWS Management Console
- Select the EC2 Service from the Services -> Compute -> EC2
- Click the button "Launch instance"
- Select AMI-ID ami-09aa29230f09bb1ea
    - CentOS 7.8 2003
    - User openshift in groups wheel and docker
    - bootstrap script pre-installed
- Choose an Instance Type with at least 16GiB Memory and at least 4 vCPUs (e.g. t2.xlarge, or t2.2xlarge if there is an intent to run builds and deploy applications)
- Configure at least 40GiB disk size (or 100GiB if there is an intent to run builds and deploy applications)
- Create a key pair required to log into the EC2 instance and store the pem file locally
- The security group ods-dev-env-security-group or equivalent should be used
    - opens port 22 for ssh connections
    - opens port range 3389 for VNC connections to support RDP
    - opens 8080 (for Jira)
- Launch the EC2 instance
- Review the EC2 instance details and take note of
    - the path to the key pem file PATH_TO_PEM_FILE
    - the public DNS of the new EC2 instance EC2_PUBLIC_DNS
- When the EC2 instance has become available log into the vm
    - ssh: ssh -i PATH_TO_PEM_FILE.pem openshift@EC2_PUBLIC_DNS
    - MS Remote Desktop Client -> EC2_PUBLIC_DNS
- When logged into the EC2 instance as user openshift, run the command ```bootstrap```

## Misc
To find the AMI for the latest version of Cent OS 7:
```
aws ec2 describe-images \
  --owners 679593333241 \
  --filters \
      Name=name,Values='CentOS Linux 7 x86_64 HVM EBS*' \
      Name=architecture,Values=x86_64 \
      Name=root-device-type,Values=ebs \
  --query 'sort_by(Images, &Name)[-1].ImageId' \
  --output text
```

# Containerized Jira setup including license

## Setup strategy
Atlassian recommends for unattended Jira installation to manually create a Jira instance, configure it and add add a license, then to backup the file <installation-directory>/.install4j/response.varfile, and use it to configure new Jira instances as in
```
$ atlassian-jira-software-X.X.X-x64.bin -q -varfile response.varfile
```

For automated license management the community recommends to backup the Jira database - or at least the table **productlicense** and import it into the Jira schema of new instances.

## Sample commands
```
# create mysql container
docker container run -dp 3306:3306 \
    -e "MYSQL_ROOT_PASSWORD=jiradbrpwd" \
    -v /home/$USER/mysql_data:/var/lib/mysql --name mysql  mysql:5.7 --default-storage-engine=INNODB \
    --character-set-server=utf8mb4 \
    --collation-server=utf8mb4_unicode_ci \
    --default-storage-engine=INNODB \
    --innodb-default-row-format=DYNAMIC \
    --innodb-large-prefix=ON \
    --innodb-file-format=Barracuda \
    --innodb-log-file-size=2G

# find out ip of mysql container
mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' mysql)

# connect into mysql database
docker container run -it --rm mysql:5.7 mysql -h ${mysql_ip} -u root -p
create database jiradb character set utf8mb4 collate utf8mb4_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX on jiradb.* TO 'jira_user'@'%' IDENTIFIED BY 'jira_password';
flush privileges;

docker container run --name jira -v $HOME/jiira_data:/var/atlassian/application-data/jira -dp 8080:8080 \
    -e "ATL_JDBC_URL=jdbc:mysql://$mysql_ip:3306/jiradb" \
    -e ATL_JDBC_USER=jira_user \
    -e ATL_JDBC_PASSWORD=jira_password \
    -e ATL_DB_DRIVER=com.mysql.jdbc.Driver \
    -e ATL_DB_TYPE=mysql \
    atlassian/jira-software:8.5.3 && docker container logs -f jira

```
## Atlassian licenses
The EDP/ODS development environment makes use of the Atlassian timebomb licenses as available on https://developer.atlassian.com/platform/marketplace/timebomb-licenses-for-testing-server-apps/.

### Jira License - 3 hour expiration for all Atlassian host products*
AAACLg0ODAoPeNqNVEtv4jAQvudXRNpbpUSEx6FIOQBxW3ZZiCB0V1WllXEG8DbYke3A8u/XdUgVQ
yg9ZvLN+HuM/e1BUHdGlNvuuEHQ73X73Y4bR4nbbgU9ZwFiD2IchcPH+8T7vXzuej9eXp68YSv45
UwoASYhOeYwxTsIE7RIxtNHhwh+SP3a33D0XnntuxHsIeM5CIdwtvYxUXQPoRIF6KaC0FUGVlEB3
v0hOAOWYiH9abFbgZith3i34nwOO65gsAGmZBhUbNC/nIpjhBWEcefJWelzqIDPWz/OtjmXRYv2X
yqwnwueFkT57x8e4cLmbCD1QnX0UoKQoRc4EUgiaK4oZ2ECUrlZeay75sLNs2JDmZtWR8oPCfWZG
wHAtjzXgIo0SqmZiKYJmsfz8QI5aI+zApuq6fqJKVPAMCPnNpk4LPW6kBWgkZb+kQAzzzS2g6Dnt
e69Tqvsr4SOskIqEFOeggz1v4zrHbr0yLJR8rU64FpQpVtBy1mZxM4CnHC9Faf8tKMnTF1AiXORF
ixyQaWto3RZ+ncWLXtMg6EnKZZRpmQNb2R8tnJXFulCfXmXLry7TrHBWn2HNVyH8WYxj9AzmsxiN
L/R88Xg6rA1lVs4QpO5titxhplJcCY2mFFZLutAZVhKipm15/VhJx36YVqyN8YP7IaGC1+lwnJ7Q
5pJpNmxk5hP3qovutY8Pi4E2WIJ59esnr1p+T6eD67teBVCHf+ga+ho4/4D9YItZDAsAhQ5qQ6pA
SJ+SA7YG9zthbLxRoBBEwIURQr5Zy1B8PonepyLz3UhL7kMVEs=X02q6

## Resources
- Jira 8.5 unattended installation: https://confluence.atlassian.com/adminjiraserver085/unattended-installation-981154569.html
- Automated license management: https://community.atlassian.com/t5/Jira-questions/Fully-automated-installation-configuration-of-JIRA/qaq-p/147413
- Configure Jira against mysql db: https://confluence.atlassian.com/adminjiraserver/connecting-jira-applications-to-mysql-5-7-966063305.html
- MySQL on Docker Hub: https://hub.docker.com/_/mysql
- Jira on Docker Hub: https://hub.docker.com/r/atlassian/jira-software
- RDP on CentOS 7 
  - https://www.itzgeek.com/how-tos/linux/centos-how-tos/install-xrdp-on-centos-7-rhel-7.html
  - https://darrenoneill.eu/?p=421
