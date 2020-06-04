#!/usr/bin/env bash

set -eu

atlassian_mysql_container_name=atlassian_mysql
atlassian_mysql_port=3306
atlassian_mysql_version=5.7
atlassian_crowd_software_version=3.7.0
atlassian_crowd_container_name=crowd
atlassian_crowd_port=48080
atlassian_crowd_port_internal=8095
atlassian_crowd_ip=
atlassian_jira_container_name=jira
atlassian_jira_db_name=jiradb
atlassian_jira_software_version=8.5.3
atlassian_jira_ip=
atlassian_jira_port=18080
# docker network internal jira port
atlassian_jira_port_internal=8080
atlassian_bitbucket_container_name=bitbucket
atlassian_bitbucket_db_name=bitbucketdb
atlassian_bitbucket_version=6.8.2-jdk11
atlassian_bitbucket_ip=
atlassian_bitbucket_port=28080
# docker network internal bitbucket port
atlassian_bitbucket_port_internal=7990
# Backup files
atlassian_mysql_dump_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/mysql_data.tar.gz
atlassian_jira_backup_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/jira_data.tar.gz
atlassian_bitbucket_backup_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/bitbucket_data.tar.gz

# TODO add global openshift_user, openshift_password and use them when creating ods-core.env for improved configurability

# Will be used in oc cluster up as --public-hostname and part of the --routing-suffix
# TODO make this value configurable, can then be set e.g. by bootstrap script or other clients
public_hostname=$(hostname -i)
echo "OpenShift ip will be ${public_hostname}"

NAMESPACE=ods

function display_usage() {
    echo
    echo "This script provides functions to install and configure various parts of an EDP/ODS installation."
    echo "Functions in this script can be called like in the sample calls below:"
    echo "deploy.sh display_usage"
    echo "deploy.sh install_docker"
    echo "deploy.sh startup_atlassian_bitbucket"
    echo
    echo "Since several of the functions will require that other functions have prepared the system first,"
    echo "the script provides utility functions like basic_vm_setup which will call functions in this"
    echo "setup script in a proper sequence."
}

#######################################
# Fix the CentOS 7 setup before starting Openshift / ODS setup.
# - Install modern git version.
# - override ll alias
# - install golang, jq, tree
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function check_system_setup() {
    # print warning if hypervisor application support is not activated - interesting for local VMWare VMs
    if [[ -z $(grep vmx /proc/cpuinfo) ]]; then
        echo "WARNING: The VM needs to be configured to enable hypervisor applications."
        echo "If you are on an AWS ECS instance you can ignore this warning."
    fi

    echo "alias ll='ls -AFhl --color=auto'" >> ~/.bashrc
    echo "alias dcip='docker inspect --format "{{.NetworkSettings.IPAddress}}"'" >> ~/.bashrc
    echo "alias lsop='sudo lsof +c 15 -nP -iTCP -sTCP:LISTEN'" >> ~/.bashrc

    # suppress sudo timeout
    sudo sed -ie "\$aDefaults    env_reset,timestamp_timeout=-1" /etc/sudoers

    # remove obsolete version of git
    if [[ ! -z $(command -v git) ]]; then sudo yum remove -y git*; fi
    sudo yum update -y
    sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
    sudo yum -y install firewalld git2u-all glances golang jq tree

    if ! systemctl status firewalld | grep -i running; then
        systemctl start firewalld
    fi
}

#######################################
# Optionally, install Vistual Studio Code
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_vscode() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    cat <<EOF |
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    sudo tee /etc/yum.repos.d/vscode.repo
    sudo yum install -y code
}

#######################################
# The provisioning app requires Google Chrome.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_google_chrome() {
    if [[ -z $(command -v google-chrome) ]]
    then
        curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
        sudo yum install -y ./google-chrome-stable_current_*.rpm
        rm ./google-chrome-stable_current_*.rpm
    fi
}

#######################################
# Install remote desktop protocol.
# Connect to the openshift user session using MS Remote Desktop.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_rdp() {
    sudo yum install -y yum-utils epel-release https://centos7.iuscommunity.org/ius-release.rpm
    sudo yum -y install xrdp
    sudo systemctl start xrdp
    sudo netstat -antup | grep xrdp
    sudo systemctl enable xrdp
    sudo chcon --type=bin_t /usr/sbin/xrdp
    sudo chcon --type=bin_t /usr/sbin/xrdp-sesman
    sudo lsof +c 15 -nP -iTCP -sTCP:LISTEN
    sudo firewall-cmd --zone=public --permanent --add-port=3389/tcp
    sudo firewall-cmd --zone=public --permanent --add-port=3350/tcp
    sudo firewall-cmd --reload
}

#######################################
# Sets up the docker daemon, installs docker-compoase and configures insecure registries.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function install_docker() {
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum -y install docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker

    echo "updating docker insecure registries"
    cat <<EOF |
    {
        "bip": "172.17.0.1/16",
        "default-address-pools": [
            {
                "base": "172.17.0.0/16",
                "size": 24
            }
        ],
        "insecure-registries": [
            "172.30.0.0/16"
        ]
    }
EOF
    sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker.service
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    if [[ ! -f /usr/bin/docker-compose ]]; then
        sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.25.5/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    # you can run this statement in your session to get docker-compose bash completion. Will be available in a new session anyway.
    # source /etc/bash_completion.d/docker-compose

    echo "Configuring firewall for docker containers:"
    sudo firewall-cmd --permanent --new-zone dockerc
    sudo firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
    sudo firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
    sudo firewall-cmd --permanent --zone dockerc --add-port 53/udp
    sudo firewall-cmd --permanent --zone dockerc --add-port 8053/udp
    sudo firewall-cmd --reload
}

#######################################
# set up an OKD cluster 3.11 ready for ODS integration
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_openshift_cluster() {
    echo "Installing OpenShift client"
    sudo yum install -y centos-release-openshift-origin311
    sudo yum install -y origin-clients
    source /etc/bash_completion.d/oc

    echo "Starting up oc cluster for the first time"
    # ip_address=192.168.188.96
    ip_address=172.17.0.1
    oc cluster up --base-dir=${HOME}/openshift.local.clusterup --routing-suffix ${ip_address}.nip.io --public-hostname ${ip_address} --no-proxy=${ip_address}
    oc login -u developer
    oc login -u system:admin
    oc projects
    oc adm policy add-cluster-role-to-user cluster-admin developer
    # allow for OpenShifts to be resolved within OpenShift network
    sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT

    # TODO create a test project to verify cluster works, remove after development phase
    echo "Create a simple test project to smoke test OpenShift cluster"
    oc -o yaml new-app php~https://github.com/sandervanvugt/simpleapp --name=simpleapp > s2i.yaml
    oc create -f s2i.yaml
    rm s2i.yaml
}

#######################################
# install tailor v0.13.1
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function download_tailor() {
    echo "Download tailor"
    curl -LO "https://github.com/opendevstack/tailor/releases/download/v0.13.1/tailor-linux-amd64"
    chmod +x tailor-linux-amd64
    sudo mv tailor-linux-amd64 /usr/bin/tailor
}

#######################################
# list versions of software installed in the basic setup
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function print_system_setup() {
    echo "network interfaces: $(ip a)"
    echo "tailor version: $(tailor version)"
    echo "oc version: $(oc version)"
    echo "jq version: $(jq --version)"
    echo "go version: $(go version)"
    echo "git version: $(git --version)"
    echo "docker version: $(docker --version)"
}

#######################################
# Retrieve database dump and backup files for Atlassian stack components
# initialized with timebomb licenses and ODS users from backup in the cloud.
# If someone would rather start with a clean state and provide licenses and
# basic configuration manually, this function should be skipped in the setup.
# This function will try to clean up old states by deleting local folders
# mapped to docker volumes etc. So, it should not be called in a running
# system.
# process.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function prepare_atlassian_stack() {
    echo "Downloading data dumps for Atlassian stack."
    pushd "/home/${USER}"
    curl -LO ${atlassian_mysql_dump_url}
    curl -LO ${atlassian_jira_backup_url}
    curl -LO ${atlassian_bitbucket_backup_url}
    echo "Extracting files"
    for data_file in bitbucket_data jira_data mysql_data
    do
        # cleaning up (stale) files and folders
        rm -rf "/home/${USER}/${data_file}"
        # download and expand archives
        tar xzf "${data_file}.tar.gz"
        rm "${data_file}.tar.gz"
    done
    popd
    echo "Finished downloading and extracting Atlassian stack data dumps."
}

#######################################
# Start up a containerized mysql instance capable of hosting Atlassian databases
# for Jira, BitBucket, Confluence.
# Globals:
#   atlassian_mysql_container_name
#   atlassian_mysql_port
#   atlassian_mysql_version
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function startup_atlassian_mysql() {
    echo "Setting up a mysql instance for the Atlassian tool suite."
    docker container run -dp ${atlassian_mysql_port}:3306 \
        --name ${atlassian_mysql_container_name} \
        --health-cmd "mysqladmin ping --silent" \
        -e "MYSQL_ROOT_PASSWORD=jiradbrpwd" \
        -v /home/${USER}/mysql_data:/var/lib/mysql mysql:${atlassian_mysql_version} --default-storage-engine=INNODB \
        --character-set-server=utf8 \
        --collation-server=utf8_bin \
        --default-storage-engine=INNODB \
        --innodb-default-row-format=DYNAMIC \
        --innodb-large-prefix=ON \
        --innodb-file-format=Barracuda \
        --innodb-log-file-size=2G \
        > jira_startup.log 2>&1 # reduce noise in log output from docker image download
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "The Atlassian mysql instance is listening on ${mysql_ip}:${atlassian_mysql_port}"
}

#######################################
# Will use startup_atlassian_mysql to start a mysql database in a docker
# container and hold execution until mysql becomes available und client
# services like the Atlassian stack can safely be started.
# Globals:
#   atlassian_mysql_container_name
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function startup_and_follow_atlassian_mysql() {
    startup_atlassian_mysql
    printf "Waiting for mysqld to become available"
    until [[ $(docker inspect --format '{{.State.Health.Status}}' ${atlassian_mysql_container_name}) == 'healthy' ]]
    do
        printf .
        sleep 1
    done
    echo "mysqld up and running."
}

function startup_and_follow_bitbucket() {
    startup_atlassian_bitbucket
    printf "Waiting for bitbucket to become available"
    until [[ $(docker inspect --format '{{.State.Health.Status}}' ${atlassian_bitbucket_container_name}) == 'healthy' ]]
    do
        printf .
        sleep 1
    done
    echo "bitbucket up and running."
}

#######################################
# Start up a containerized Jira instance, connecting against a database
# provided by atlassian_mysql_container_name
# Globals:
#   atlassian_jira_software_version
#   atlassian_jira_db_name
#   atlassian_mysql_container_name
#   atlassian_mysql_port
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function startup_atlassian_jira() {
    echo "Starting Atlassian Jira ${atlassian_jira_software_version}"
    local mysql_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})

    echo "Downloading mysql-connector-java"
    local download_dir="downloads_jira"
    local download_url="https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar"
    local db_driver_file="mysql-connector-java-8.0.20.jar"
    download_file_to_folder "${download_url}" "${download_dir}"

    docker container run \
        --name ${atlassian_jira_container_name} \
        -v $HOME/jira_data:/var/atlassian/application-data/jira \
        -dp ${atlassian_jira_port}:8080 \
        -e "ATL_JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_jira_db_name}" \
        -e ATL_JDBC_USER=jira_user \
        -e ATL_JDBC_PASSWORD=jira_password \
        -e ATL_DB_DRIVER=com.mysql.jdbc.Driver \
        -e ATL_DB_TYPE=mysql \
        -e ATL_DB_SCHEMA_NAME= \
        atlassian/jira-software:${atlassian_jira_software_version} \
        > jira_startup.log 2>&1 # reduce noise in log output from docker image download
    local jira_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_jira_container_name})

    echo -n "Preparing jira container for connection to local mysql database."
    prepare_jira_container "${download_dir}"
    while ! (docker container exec -i jira bash -c "grep -q ${mysql_ip} dbconfig.xml")
    do
        # this race condition of the container getting ready and writing to dbconfig.xml
        # normally works out. If it should fail on 1st try, try again ...
        # Alternative approach: start container, stop container, cp driver, restart container ...
        sleep 1
        echo -n "."
        prepare_jira_container "${download_dir}"
    done
    echo "done"

    rm -rf "${download_dir}"
    inspect_jira_ip
    echo "Atlassian jira-software is listening on ${jira_ip}:${atlassian_jira_port_internal} and ${public_hostname}:${atlassian_jira_port}"
}

function prepare_jira_container() {
    local download_dir="${1:?null}"
    docker container cp "${download_dir}/mysql-connector-java-8.0.20.jar" jira:/opt/atlassian/jira/lib/
    docker container exec -i jira bash -c "sed -i \"s|172.17.0.6|${mysql_ip}|\" dbconfig.xml"
}

#######################################
# Start up a containerized Crowd instance, connecting against a database
# provided by atlassian_mysql_container_name
# Globals:
#   atlassian_crowd_software_version
#   atlassian_crowd_container_name
#   atlassian_crowd_port
#   atlassian_crowd_port_internal
#
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function startup_atlassian_crowd() {

    echo "Starting Atlassian Crowd ${atlassian_crowd_software_version} installation"
    docker volume create --name odsCrowdVolume
    docker container run \
        -v odsCrowdVolume:/var/atlassian/application-data/crowd \
        --name="crowd" \
        -dp ${atlassian_crowd_port}:${atlassian_crowd_port_internal} \
        atlassian/crowd:${atlassian_crowd_software_version}

    sleep 3

    echo
    echo "...copy config 'crowd-provision-app-backup.xml' to container"
    docker container exec crowd bash -c "mkdir -p /var/atlassian/application-data/crowd/shared/; chown crowd:crowd /var/atlassian/application-data/crowd/shared/"
    docker cp ${BASH_SOURCE%/*}/crowd-provision-app-backup.xml crowd:/var/atlassian/application-data/crowd/shared/

    echo
    echo "...change permission of config in container"
    docker exec -it crowd bash -c 'chown crowd:crowd /var/atlassian/application-data/crowd/shared/crowd-provision-app-backup.xml; ls -lart /var/atlassian/application-data/crowd/shared/'

    sleep 1

    echo
    echo "...ping crowd web server"
    curl --silent --location --request -GET "http://localhost:$atlassian_crowd_port/" -v

    # Get session cookie
    echo
    echo "...get session cookie from crowd web console"
    curl --silent --location --request GET "http://localhost:$atlassian_crowd_port/crowd/console/" -c crowd_sessionid_cookie.txt

    sleep 1

    # Set time limited license
    echo
    echo "...setup license"
    curl --silent --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setuplicense!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'key=AAACLg0ODAoPeNqNVEtv4jAQvudXRNpbpUSEx6FIOQBxW3ZZiCB0V1WllXEG8DbYke3A8u/XdUgVQ
yg9ZvLN+HuM/e1BUHdGlNvuuEHQ73X73Y4bR4nbbgU9ZwFiD2IchcPH+8T7vXzuej9eXp68YSv45
UwoASYhOeYwxTsIE7RIxtNHhwh+SP3a33D0XnntuxHsIeM5CIdwtvYxUXQPoRIF6KaC0FUGVlEB3
v0hOAOWYiH9abFbgZith3i34nwOO65gsAGmZBhUbNC/nIpjhBWEcefJWelzqIDPWz/OtjmXRYv2X
yqwnwueFkT57x8e4cLmbCD1QnX0UoKQoRc4EUgiaK4oZ2ECUrlZeay75sLNs2JDmZtWR8oPCfWZG
wHAtjzXgIo0SqmZiKYJmsfz8QI5aI+zApuq6fqJKVPAMCPnNpk4LPW6kBWgkZb+kQAzzzS2g6Dnt
e69Tqvsr4SOskIqEFOeggz1v4zrHbr0yLJR8rU64FpQpVtBy1mZxM4CnHC9Faf8tKMnTF1AiXORF
ixyQaWto3RZ+ncWLXtMg6EnKZZRpmQNb2R8tnJXFulCfXmXLry7TrHBWn2HNVyH8WYxj9AzmsxiN
L/R88Xg6rA1lVs4QpO5titxhplJcCY2mFFZLutAZVhKipm15/VhJx36YVqyN8YP7IaGC1+lwnJ7Q
5pJpNmxk5hP3qovutY8Pi4E2WIJ59esnr1p+T6eD67teBVCHf+ga+ho4/4D9YItZDAsAhQ5qQ6pA
SJ+SA7YG9zthbLxRoBBEwIURQr5Zy1B8PonepyLz3UhL7kMVEs=X02q6'

    sleep 1

    # Set install type action
    echo
    echo "...start crowd configuration"
    curl --silent --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/installtype!update.action?installOption=install.xml" -b crowd_sessionid_cookie.txt

    sleep 1

    # Set setup database option to embedded
    echo
    echo "...choose embedded db option"
    curl --silent --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setupdatabase!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'databaseOption= db.embedded' \
--form 'jdbcDatabaseType= ' \
--form 'jdbcDriverClassName= ' \
--form 'jdbcUrl= ' \
--form 'jdbcUsername= ' \
--form 'jdbcPassword= ' \
--form 'jdbcHibernateDialect= ' \
--form 'datasourceDatabaseType= ' \
--form 'datasourceJndiName='

    sleep 1

    # Restore configuration from the backup file
    echo
    echo "...choose install with config file (config file was copied to container already)"
    curl --silent --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setupimport!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'filePath=/var/atlassian/application-data/crowd/shared/crowd-provision-app-backup.xml'

    sleep 1

    # Test setup by login into crowd
    echo
    echo "...login in crowd to test installation"
curl --silent --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/login.action" \
-b crowd_sessionid_cookie.txt \
--header 'Content-Type: text/plain' \
--data '{username: "openshift", password: "openshift", rememberMe: false}'

    sleep 1

    local crowd_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_crowd_container_name})

    echo
    echo "Atlassian Crowd installation is done and server listening on http://${crowd_ip}:${atlassian_crowd_port_internal} and ${public_hostname}:${atlassian_crowd_port}"
    echo

}

# Helper function for local development of crowd setup
function crowd_cleanup() {
    docker stop crowd
    docker container rm crowd
    docker volume rm odsCrowdVolume
    docker container ls -a
}

# Helper function for local development of crowd setup
function crowd_echo_backup_cmd() {
    echo "To copy from `crowd` container the backup file to local folder:"
    echo "1. copy this docker command:"
    echo "docker cp crowd:/var/atlassian/application-data/crowd/shared/backups/<BACKUP_FILE_NAME>.xml ."
    echo "2. replace 'BACKUP_FILE_NAME' with one backup file from this list:"
    docker exec -it crowd bash -c "cd /var/atlassian/application-data/crowd/shared/backups/; ls"
    echo "3. and run the command"
}

#######################################
# Initialize Jira database. Requires database service to be running.
# Is to be used mutually exclusively with prepare_atlassian_stack.
# Globals:
#   atlassian_jira_db_name
#   atlassian_mysql_container_name
#   atlassian_mysql_port
#   atlassian_mysql_version
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function initialize_atlassian_jiradb() {
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Setting up jiradb on ${mysql_ip}:${atlassian_mysql_port}."
    echo "jiradbrpwd" | docker container run -i --rm mysql:${atlassian_mysql_version} mysql -h ${mysql_ip} -u root -p -e \
        "create database ${atlassian_jira_db_name} character set utf8 collate utf8_bin; \
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX,CREATE TEMPORARY TABLES on jiradb.* TO 'jira_user'@'%' IDENTIFIED BY 'jira_password'; \
        flush privileges;"
}

#######################################
# Will download the file specified by the url in the 1st argument
# and save it to the download directory specified
# Globals:
#   n/a
# Arguments:
#   url             for file to download
#   download_dir    relative path to the folder where client will expect to find the downloaded file
# Returns:
#   None
#######################################
function download_file_to_folder() {
    # fail if 2 expected arguments are not provided
    echo "Expecting download URL and download directory as arguments ..."
    local download_url="${1:?null}"
    local download_dir="${2:?null}"
    echo "Going to download ${download_url} to ${download_dir}."

    mkdir -p "${download_dir}"
    pushd "${download_dir}"
        curl -LO "${download_url}"
    popd
}

#######################################
# Start up a containerized BitBucket instance, connecting against a database
# provided by atlassian_mysql_container_name
# Globals:
#   atlassian_bitbucket_version
#   atlassian_bitbucket_db_name
#   atlassian_mysql_container_name
#   atlassian_mysql_port
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function startup_atlassian_bitbucket() {
    echo "Strating up Atlassian BitBucket ${atlassian_bitbucket_version}"
    local mysql_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})

    echo "Downloading mysql-connector-java"
    local download_dir="downloads_bitbucket"
    local download_url="https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar"
    local db_driver_file="mysql-connector-java-8.0.20.jar"
    download_file_to_folder "${download_url}" "${download_dir}"

    docker container run \
        --name ${atlassian_bitbucket_container_name} \
        --health-cmd '[ ! -z $(curl -X GET --user openshift:openshift http://localhost:7990/rest/api/1.0/projects) ]' \
        -v ${HOME}/bitbucket_data:/var/atlassian/application-data/bitbucket \
        -dp ${atlassian_bitbucket_port}:7990 \
        -e "JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_bitbucket_db_name}" \
        -e JDBC_DRIVER=com.mysql.jdbc.Driver \
        -e JDBC_USER=bitbucket_user \
        -e JDBC_PASSWORD=bitbucket_password \
        atlassian/bitbucket-server:${atlassian_bitbucket_version} \
        > jira_startup.log 2>&1 # reduce noise in log output from docker image download

    local bitbucket_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_bitbucket_container_name})
    docker container exec bitbucket bash -c "mkdir -p /var/atlassian/application-data/bitbucket/lib; chown bitbucket:bitbucket /var/atlassian/application-data/bitbucket/lib"
    docker container cp "${download_dir}/${db_driver_file}" bitbucket:/var/atlassian/application-data/bitbucket/lib/mysql-connector-java-8.0.20.jar
    rm -rf "${download_dir}"
    inspect_bitbucket_ip
    echo "Atlassian BitBucket is listening on ${bitbucket_ip}:${atlassian_bitbucket_port_internal} and ${public_hostname}:${atlassian_bitbucket_port}"
}

#######################################
# Initialize bitbucket database. Requires a database service to be running.
# Is to be used mutually exclusively with prepare_atlassian_stack.
# Globals:
#   atlassian_bitbucket_db_name
#   atlassian_mysql_container_name
#   atlassian_mysql_port
#   atlassian_mysql_version
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function initialize_atlassian_bitbucketdb() {
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Setting up bitbucket database on ${mysql_ip}:${atlassian_mysql_port}."
    echo "jiradbrpwd" | docker container run -i --rm mysql:${atlassian_mysql_version} mysql -h ${mysql_ip} -u root -p -e \
        "create database ${atlassian_bitbucket_db_name} character set utf8 collate utf8_bin; \
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX,CREATE TEMPORARY TABLES on bitbucketdb.* TO 'bitbucket_user'@'%' IDENTIFIED BY 'bitbucket_password'; \
        flush privileges;"
}

#######################################
# The automated ODS setup requires some repositories to be existing in the
# local bitbucket installation. This function takes care of it.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function create_empty_ods_repositories() {
    # creating project opendevstack if it does not exist yet
    if [[ -z $(curl -sX GET --user openshift:openshift http://${public_hostname}:${atlassian_bitbucket_port}/rest/api/1.0/projects | jq '.values[] | select(.key=="OPENDEVSTACK") | .key ') ]]; then
        echo "Creating project opendevstack in BitBucket"
        curl -X POST --user openshift:openshift http://${public_hostname}:${atlassian_bitbucket_port}/rest/api/1.0/projects \
            -H "Content-Type: application/json" \
            -d "{\"key\":\"OPENDEVSTACK\", \"name\": \"opendevstack\", \"description\": \"OpenDevStack\"}"
    else
        echo "Found project opendevstack in BitBucket."
    fi
    # The repository list in the next line can be modified to project specific needs.
    # For each of the listed names, a repository will be created in the local bitbucket
    # instance under the OPENDEVSTACK project. The list should be synced with the repo
    # list in ods-core/ods-setup/repos.sh.
    for repository in ods-core ods-quickstarters ods-jenkins-shared-library ods-provisioning-app ods-configuration; do
        echo "Creating repository ${repository} on http://${public_hostname}:${atlassian_bitbucket_port}."
        curl -X POST --user openshift:openshift http://${public_hostname}:${atlassian_bitbucket_port}/rest/api/1.0/projects/opendevstack/repos \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"${repository}\", \"scmId\": \"git\", \"forkable\": true}" | jq .
    done
}

#######################################
# For each of the listed names this function will delete the corresponding
# repository in the local BitBucket instance in the opendevstack project
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function delete_ods_repositories() {
    for repository in ods-core ods-quickstarters ods-jenkins-shared-library ods-provisioning-app ods-configuration; do
        echo "Deleting repository opendevstack/${repository} on http://${public_hostname}:${atlassian_bitbucket_port}."
        curl -X DELETE --user openshift:openshift http://${public_hostname}:${atlassian_bitbucket_port}/rest/api/1.0/projects/opendevstack/repos/${repository}
    done
}

#######################################
# Makes use of ods-core/ods-setup-repos.sh to clone ods repositories from github
# and push them to the local BitBucket instance.
# Globals:
#   atlassian_bitbucket_port
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function initialise_ods_repositories() {
    local opendevstack_dir="/home/${USER}/opendevstack"

    mkdir -p "${opendevstack_dir}"
    pushd "${opendevstack_dir}"
    # curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/master/ods-setup/repos.sh
    curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/feature/ods-devenv/ods-setup/repos.sh
    chmod u+x ./repos.sh
    ./repos.sh --init --confirm --source-git-ref feature/ods-devenv --target-git-ref feature/ods-devenv --bitbucket http://openshift:openshift@${public_hostname}:${atlassian_bitbucket_port} --verbose
    ./repos.sh --sync --bitbucket http://openshift:openshift@${public_hostname}:${atlassian_bitbucket_port} --source-git-ref feature/ods-devenv --target-git-ref feature/ods-devenv --confirm
    popd
}

function inspect_bitbucket_ip() {
    atlassian_bitbucket_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_bitbucket_container_name})
}

function inspect_jira_ip() {
    atlassian_jira_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_jira_container_name})
}

function inspect_crowd_ip() {
    atlassian_crowd_ip=$(docker container inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_crowd_container_name})
}

#######################################
# Creates a config file and uploads it into ods-configuration repository on
# the local BitBucket instance.
# Globals:
#   atlassian_bitbucket_ip
#   atlassian_bitbucket_port_internal
#   atlassian_jira_ip
#   atlassian_jira_port_internal
#   public_hostname
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function create_configuration() {
    echo "create configuration"
    pwd
    ods-setup/config.sh --verbose --bitbucket http://openshift:openshift@${public_hostname}:${atlassian_bitbucket_port}
    pushd ../ods-configuration
    git init
    # keep ods-core.env.sample as a reference
    # echo "ods-core.env.sample" > .gitignore

    if [[ -z ${atlassian_bitbucket_ip} ]]; then
        # can happen if script functions are called selectively
        inspect_bitbucket_ip
    fi
    if [[ -z ${atlassian_jira_ip} ]]; then
        # can happen if script functions are called selectively
        inspect_jira_ip
    fi
    if [[ -z ${atlassian_crowd_ip} ]]
    then
        inspect_crowd_ip
    fi

    if ! git remote | grep origin; then
        git remote add origin http://openshift:openshift@${public_hostname}:${atlassian_bitbucket_port}/scm/opendevstack/ods-configuration.git
    fi
    git add -- .
    git commit -m "initial commit"
    git push --set-upstream origin master
    # base64('changeit') -> Y2hhbmdlbWUK
    sed -i "s|ODS_GIT_REF=.*$|ODS_GIT_REF=feature/ods-devenv|" ods-core.env
    sed -i "s/cd.192.168.56.101.nip.io/ods.${public_hostname}.nip.io/" ods-core.env
    sed -i "s|JIRA_URL=http://192.168.56.31:8080|JIRA_URL=http://${atlassian_jira_ip}:${atlassian_jira_port_internal}|" ods-core.env
    sed -i "s|BITBUCKET_HOST=192.168.56.31:7990|BITBUCKET_HOST=${atlassian_bitbucket_ip}:${atlassian_bitbucket_port_internal}|" ods-core.env
    sed -i "s|BITBUCKET_URL=http://192.168.56.31:7990|BITBUCKET_URL=http://${atlassian_bitbucket_ip}:${atlassian_bitbucket_port_internal}|" ods-core.env
    sed -i "s|REPO_BASE=http://192.168.56.31:7990/scm|REPO_BASE=http://${atlassian_bitbucket_ip}:${atlassian_bitbucket_port_internal}/scm|" ods-core.env

    sed -i "s|CD_USER_ID=.*$|CD_USER_ID=openshift|" ods-core.env
    sed -i "s|CD_USER_ID_B64=.*$|CD_USER_ID_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|CD_USER_PWD_B64=.*$|CD_USER_PWD_B64=$(echo -n openshift | base64)|" ods-core.env

    ## NEXUS
    sed -i "s|NEXUS_USERNAME=.*$|NEXUS_USERNAME=admin|" ods-core.env
    sed -i "s|NEXUS_PASSWORD=.*$|NEXUS_PASSWORD=openshift|" ods-core.env
    sed -i "s|NEXUS_PASSWORD_B64=.*$|NEXUS_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|NEXUS_AUTH=.*$|NEXUS_AUTH=admin:openshift|" ods-core.env

    # SONARQUBE
    sed -i "s|SONARQUBE_HOST=.*$|SONARQUBE_HOST=sonarqube-ods.${public_hostname}.nip.io|" ods-core.env
    sed -i "s|SONARQUBE_URL=.*$|SONARQUBE_URL=https://sonarqube-ods.${public_hostname}.nip.io|" ods-core.env
    # SONAR_ADMIN_USERNAME appears to have to be admin
    # sed -i "s|SONAR_ADMIN_USERNAME=.*$|SONAR_ADMIN_USERNAME=openshift|" ods-core.env
    sed -i "s|SONAR_ADMIN_PASSWORD_B64=.*$|SONAR_ADMIN_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|SONAR_DATABASE_PASSWORD_B64=.*$|SONAR_DATABASE_PASSWORD_B64=$(echo -n sonarqube | base64)|" ods-core.env
    sed -i "s|SONAR_CROWD_PASSWORD_B64=.*$|SONAR_CROWD_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|SONAR_AUTH_TOKEN_B64=.*$|SONAR_AUTH_TOKEN_B64=$(echo -n openshift | base64)|" ods-core.env
    # Toggle value of this line when Atlassian Crowd becomes available / not-available in EDP in a box.
    sed -i "s|SONAR_AUTH_CROWD=.*$|SONAR_AUTH_CROWD=true|" ods-core.env

    # JENKINS
    sed -i "s|APP_DNS=.*$|APP_DNS=172.30.0.1|" ods-core.env
    sed -i "s|PIPELINE_TRIGGER_SECRET_B64=.*$|PIPELINE_TRIGGER_SECRET_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=openshift|" ods-core.env

    sed -i "s|IDP_DNS=[.0-9a-z]*$|IDP_DNS=|" ods-core.env
    sed -i "s/192.168.56.101/${public_hostname}/" ods-core.env

    # provisioning app settings
    sed -i "s/PROV_APP_ATLASSIAN_DOMAIN=.*$/PROV_APP_ATLASSIAN_DOMAIN=${atlassian_crowd_ip}/" ods-core.env
    sed -i "s/PROV_APP_CROWD_PASSWORD=.*$/PROV_APP_CROWD_PASSWORD=ods/" ods-core.env
    sed -i "s|CROWD_URL=.*$|CROWD_URL=http://${atlassian_crowd_ip}:${atlassian_crowd_port_internal}/crowd|" ods-core.env

    git add -- .
    git commit -m "updated config for EDP box"
    git push
    popd
}

function install_ods_project() {
    ods-setup/setup-ods-project.sh --namespace ods --reveal-secrets --verbose --non-interactive
}

#######################################
# Sets up Nexus as a service in OpenShift.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_nexus() {
    echo "make install-nexus: / apply-nexus:"
    pushd nexus/ocp-config
    tailor apply --namespace ${NAMESPACE} --non-interactive --verbose
    popd


    echo "make configure-nexus:"
    pushd nexus
    local nexus_url="https://$(oc -n ods get route nexus -ojsonpath={.spec.host})"
    local nexus_port=$(oc -n ods get route nexus -ojsonpath={.spec.port.targetPort})
    nexus_port=${nexus_port%-*} # truncate -tcp from 8081-tcp

    ./configure.sh --namespace ods --nexus=${nexus_url} --insecure --verbose --admin-password openshift
    popd

    # TODO nexus route workaround nexus_url_internal can be switched back to
    # nexus_route when:
    # - nexus_route can be resolved within OpenShift network (done)
    # - nexus ssl certificate gets accepted by all clients (e.g. scala) (open)
    # -> jenkins-slave build pods cannot resolve OpenShift routes
    local nexus_pod_name=$(oc -n ods get pods | grep nexus | cut -f 1 -d " ")
    local nexus_ip=$(oc -n ods get pod ${nexus_pod_name} -o jsonpath={.status.podIP})
    local nexus_url_internal="http://"nexus-ods.${nexus_ip}.nip.io:${nexus_port}
    local nexus_route="https://nexus-ods.${public_hostname}.nip.io"

    pushd ../ods-configuration
    sed -i "s|NEXUS_URL=.*$|NEXUS_URL=${nexus_url_internal}|" ods-core.env
    popd
}

#######################################
# Sets up SonarQube as a service in OpenShift.
# Globals:
#   NAMESPACE (e.g. ods)
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_sonarqube() {
    echo "Setting up SonarQube"
    sudo sysctl -w vm.max_map_count=262144
    echo "apply-sonarqube-build:"
    pushd sonarqube/ocp-config
    tailor apply --namespace ${NAMESPACE} bc,is --non-interactive --verbose
    popd

    echo "start-sonarqube-build:"
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config sonarqube --verbose

    echo "apply-sonarqube-deploy:"
    pushd sonarqube/ocp-config
    tailor apply --namespace ${NAMESPACE} --exclude bc,is --non-interactive --verbose
    local sonarqube_url=$(oc -n ${NAMESPACE} get route sonarqube -ojsonpath={.spec.host})
    echo "Visit ${sonarqube_url}/setup to see if any update actions need to be taken."
    popd

    echo "configure-sonarqube:"
    pushd sonarqube
    ./configure.sh --sonarqube="https://${sonarqube_url}" --verbose --insecure \
        --pipeline-user openshift \
        --pipeline-user-password openshift \
        --admin-password openshift
    popd
}

#######################################
# Sets up Jenkins and the Webhook-Proxy as services in OpenShift.
# Globals:
#   NAMESPACE (e.g. ods)
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_jenkins() {
    echo "Setting up Jenkins"
    oc policy add-role-to-user edit -z jenkins -n ${NAMESPACE}

    echo "make apply-jenkins-build:"
    pushd jenkins/ocp-config/build
    tailor apply --namespace ${NAMESPACE} --non-interactive --verbose
    popd

    echo "make start-jenkins-build:"
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-master --verbose &
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-slave-base --verbose &
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-webhook-proxy --verbose &

    local fail_count=0
    for job in $(jobs -p)
    do
        echo "Waiting for openshift build ${job} to complete."
        wait "${job}" || fail_count=$((fail_count + 1))
        echo "build job ${job} returned. Number of failed jobs is ${fail_count}"
    done
    if [[ "${fail_count}" -gt 0 ]]
    then
        echo "${fail_count} of the jenkins builds failed. Going to exit the setup script."
    fi

    echo "make apply-jenkins-deploy:"
    pushd jenkins/ocp-config/deploy
    tailor apply --namespace ${NAMESPACE} --selector template=ods-jenkins-template --non-interactive --verbose
    popd
}

#######################################
# Uses Makefile targets to setup provisioning app.
# Globals:
#   NAMESPACE (e.g. ods)
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_provisioning_app() {
    echo "Setting up provisioning app"
    echo "make apply-provisioning-app-deploy:"
    pushd ods-provisioning-app/ocp-config
    tailor apply --namespace ${NAMESPACE} is --non-interactive --verbose
    popd

    ocp-scripts/import-image-from-dockerhub.sh \
        --namespace ${NAMESPACE} \
        --image ods-provisioning-app \
        --image-tag latest \
        --target-stream ods-provisioning-app

    pushd ods-provisioning-app/ocp-config
        tailor apply --namespace ${NAMESPACE} --exclude is --non-interactive --verbose
    popd

}

#######################################
# Timebomb licenses will invalidate after 3 hours uptime of the Atlassian services.
# This utility function can be used to restart the Atlassian services.
# Depending on the number of available cores the restart can take a while.
# Restart can be monitored using glances.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restart_atlassian_suite() {
    docker container restart ${atlassian_jira_container_name} ${atlassian_bitbucket_container_name}
}

#######################################
# Sets up Jenkins slaves for various technologies, like:
# airflow, golang, maven, nodejs/angular, nodejs12, python, scala
#
# Relies on initialise_ods_repositories' having run before to create and
# initialise the opendevstack project folder with its repositories.
#
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_jenkins_slaves() {
    # these paths should have been created in create_empty_ods_repositories()
    # and initialise_ods_repositories
    local opendevstack_dir="/home/${USER}/opendevstack"
    local quickstarters_jenkins_slaves_dir="${opendevstack_dir}/ods-quickstarters/common/jenkins-slaves"
    local ocp_config_folder="ocp-config"
    local project_dir="/home/${USER}/projects"

    if [[ ! -d "${opendevstack_dir}/ods-configuration" ]]
    then
        # tailor will look for the ods-configuration folder under opendevstack_dir
        echo "Copying ods-configuration to ${opendevstack_dir}"
        cp -R "${project_dir}/ods-configuration" "${opendevstack_dir}"
    fi

    # create build configurations in parallel
    for technology in airflow golang maven nodejs10-angular nodejs12 python scala
    do
        pushd "${quickstarters_jenkins_slaves_dir}/${technology}/${ocp_config_folder}"
        echo "Creating build configuration of jenkins-slave for technology ${technology}."
        tailor apply --verbose --force --non-interactive &
        popd
    done

    local fail_count=0
    for job in $(jobs -p)
    do
        echo "Waiting for openshift build configuration ${job} to be created."
        wait "${job}" || fail_count=$((fail_count + 1))
        echo "build configuration job ${job} returned. Number of failed jobs is ${fail_count}"
    done
    if [[ "${fail_count}" -gt 0 ]]
    then
        echo "${fail_count} of the jenkins-slave build configurations failed."
    fi

    for technology in airflow golang maven nodejs10-angular nodejs12 python scala
    do
        echo "Starting build of jenkins-slave for technology ${technology}."
        oc start-build -n "${NAMESPACE}" "jenkins-slave-${technology}" --follow &
    done

    for job in $(jobs -p)
    do
        echo "Waiting for jenkins-slave builds  ${job} to complete."
        wait "${job}" || fail_count=$((fail_count + 1))
        echo "build job ${job} returned. Number of failed jobs is ${fail_count}"
    done
    if [[ "${fail_count}" -gt 0 ]]
    then
        echo "${fail_count} of the jenkins-slave builds failed."
    fi
}

#######################################
# Provide the doc-gen-service image in the OpenShift image stream
# for later use by the release manager.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function provide_document_generation_service_image() {
    pushd "ods-document-generation-svc/ocp-config"
    tailor apply --namespace ${NAMESPACE} --verbose --non-interactive
    popd

    ocp-scripts/import-image-from-dockerhub.sh \
        --namespace ${NAMESPACE} \
        --image-tag latest \
        --image ods-document-generation-svc \
        --target-stream ods-doc-gen-svc
}

#######################################
# this utility function will call some functions in a meaningful order
# to prep a fresh CentOS box for EDP/ODS installation.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function basic_vm_setup() {
    check_system_setup
    setup_rdp
    # optional
    setup_vscode
    setup_google_chrome
    install_docker
    setup_openshift_cluster
    download_tailor
    print_system_setup
    # download atlassian stack backup files for unattented setup.
    # either use prepare_atlassian_stack
    # or
    # initialize_atlassian_jiradb and initialize_atlassian_bitbucketdb
    prepare_atlassian_stack
    startup_and_follow_atlassian_mysql
    # initialize_atlassian_jiradb
    startup_atlassian_crowd
    # currently nothing is waiting on Jira to become available, can just run in
    # the background
    startup_atlassian_jira &
    # initialize_atlassian_bitbucketdb
    startup_and_follow_bitbucket
    # TODO wait until BitBucket (and Jira) becomes available
    create_empty_ods_repositories
    initialise_ods_repositories

    create_configuration
    install_ods_project
    # TODO The next 3 steps could be run in parallel
    setup_nexus
    setup_sonarqube
    setup_jenkins
    setup_provisioning_app
    setup_jenkins_slaves

    echo "Installation completed."
    echo "Now start a new terminal session or run:"
    echo "source /etc/bash_completion.d/docker-compose"
    echo "source /etc/bash_completion.d/oc"
}

# the next line will make bash try to execute the script arguments in the context of this script,
# thus supporting syntax like this:
# bash deployments.sh install_docker
# bash is used here to start a subshell in case there is an exit command in a function to not to
# kill the parent shell from where the script is getting called.
"$@"
