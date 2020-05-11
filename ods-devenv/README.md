# EDP / ODS Development Environment
This project provides scripts to setup a complete EDP environment for end-to-end testing purposes and as a development environment, aka **EDP in a box**.

The EDP box is intended to run in various environments:
- As an EC2 virtual machine on AWS
- Locally as a virtual machine powered by
  - VMWare or
  - VirtualBox

The scripts are written to be executed by an unprivileged user openshift provided in the basic VM box setup.

## Preparation steps
### Local Deployment
For local deployment create a VMWare virtual machine from CentOS-7 2003 using this configuration:
(note: these steps will be automated using Packer)
- VMWare Machine Configuration
    - 2 processor cores
    - 8 GB RAM
    - enable hypervisor applications
    - 40 GB harddisk
    - Connect network adapter
        - Configure Bridged Networking (Autodetect)
- CentOS setup
    - Timezone CEST
    - Server with GUI (Gnome)
    - create admin user openshift
        - make user admin
        - add user to docker group
    - set root user password
- Desktop Configuration
    - Install git to clone the ods-core project
    - git clone the ods-core project
    - Configure the CentOS box to requirements by running different script goals, e.g.
      - ```bash deploy.sh basic_vm_setup```
    - optionally, turn off screen lock

### AWS deployment
Use the provided AWS AMI to launch an instance of the ODS development environment
(note: these steps will be automated using Packer)
- Login to the AWS Management Console
- Select the EC2 Service from the Services -> Compute -> EC2
- Click the button "Launch instance"
- From "My AMIs" select "AWS-VMImport service: Linux - CentOS Linux release 7.7.1908 (Core)" - TODO provide AMI-ID
- Choose an Instance Type with at least 8GiB Memory and at least 2 vCPUs (e.g. t2.large)
- Configure at least 40GiB disk size
- Create a key pair required to log into the EC2 instance and store the pem file locally
- The security group ods-security-group (TODO fix naming) should be used
    - opens port 22 for ssh connections
    - opens port range 3359 for VNC connections to support RDP
- Launch the EC2 instance
- Review the EC2 instance details and take note of
    - the path to the key pem file PATH_TO_PEM_FILE
    - the public DNS of the new EC2 instance EC2_PUBLIC_DNS
- When the EC2 instance has become available you can log into the vm
    - ssh: ssh -i PATH_TO_PEM_FILE.pem openshift@EC2_PUBLIC_DNS
    - MS Remote Desktop Client -> EC2_PUBLIC_DNS

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
