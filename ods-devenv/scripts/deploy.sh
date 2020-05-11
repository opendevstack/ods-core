#!/usr/bin/env bash

set -eu

atlassian_mysql_container_name=atlassian_mysql
atlassian_mysql_port=3306
atlassian_mysql_version=5.7
atlassian_jira_db_name=jiradb
atlassian_jira_software_version=8.5.3
atlassian_jira_port=18080
atlassian_bitbucket_db_name=bitbucketdb
atlassian_bitbucket_version=6.8.2-jdk11
atlassian_bitbucket_port=28080

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

    # remove obsolete version of git
    if [[ ! -z $(command -v git) ]]; then sudo yum remove -y git*; fi
    sudo yum update -y
    sudo yum install -y yum-utils epel-release https://centos7.iuscommunity.org/ius-release.rpm
    sudo yum -y install firewalld git2u-all golang jq tree

    if ! systemctl status firewalld | grep -i running; then
        systemctl start firewalld
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
    netstat -antup | grep xrdp
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
                "size": 16
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
# set up a minishift cluster 3.11 ready for ODS integration
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
    # oc cluster up --base-dir=${HOME}/openshift.local.clusterup --routing-suffix 172.17.0.1.nip.io --public-hostname 172.17.0.1 --no-proxy=172.17.0.1
    oc cluster up --base-dir=${HOME}/openshift.local.clusterup --routing-suffix ${ip_address}.nip.io --public-hostname ${ip_address} --no-proxy=${ip_address}
    oc login -u developer
    oc login -u system:admin
    oc projects
    oc adm policy add-cluster-role-to-user cluster-admin developer

    # TODO create a test project to verify cluster works, remove after development phase
    echo "Create a simple test project to smoke test OpenShift cluster"
    oc -o yaml new-app php~https://github.com/sandervanvugt/simpleapp --name=simpleapp > s2i.yaml
    oc create -f s2i.yaml
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
        -e "MYSQL_ROOT_PASSWORD=jiradbrpwd" \
        -v /home/$USER/mysql_data:/var/lib/mysql mysql:${atlassian_mysql_version} --default-storage-engine=INNODB \
        --character-set-server=utf8 \
        --collation-server=utf8_bin \
        --default-storage-engine=INNODB \
        --innodb-default-row-format=DYNAMIC \
        --innodb-large-prefix=ON \
        --innodb-file-format=Barracuda \
        --innodb-log-file-size=2G
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "The Atlassian mysql instance is listening on ${mysql_ip}:${atlassian_mysql_port}"
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
function startup_atlassian_jira(){
    echo "Starting Atlassian Jira ${atlassian_jira_software_version}"
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Downloading mysql-connector-java"
    curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar

    docker container run \
        --name jira \
        -v $HOME/jira_data:/var/atlassian/application-data/jira \
        -dp ${atlassian_jira_port}:8080 \
        -e "ATL_JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_jira_db_name}" \
        -e ATL_JDBC_USER=jira_user \
        -e ATL_JDBC_PASSWORD=jira_password \
        -e ATL_DB_DRIVER=com.mysql.jdbc.Driver \
        -e ATL_DB_TYPE=mysql \
        -e ATL_DB_SCHEMA_NAME= \
        atlassian/jira-software:${atlassian_jira_software_version}
    # this race condition normally works out. Did not cause any trouble yet.
    # Alternative approach: start container, stop container, cp driver, restart container ...
    docker container cp mysql-connector-java-8.0.20.jar jira:/opt/atlassian/jira/lib/
    rm mysql-connector-java-8.0.20.jar
}

#######################################
# Initialize Jira database. Requires database service to be running
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
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX on jiradb.* TO 'jira_user'@'%' IDENTIFIED BY 'jira_password'; \
        flush privileges;"
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
    local mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Downloading mysql-connector-java"
    curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar

    docker container run \
        --name bitbucket \
        -v ${HOME}/bitbucket_data:/var/atlassian/application-data/bitbucket \
        -dp ${atlassian_bitbucket_port}:7990 \
        -e "JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_bitbucket_db_name}" \
        -e JDBC_DRIVER=com.mysql.jdbc.Driver \
        -e JDBC_USER=bitbucket_user \
        -e JDBC_PASSWORD=bitbucket_password \
        atlassian/bitbucket-server:${atlassian_bitbucket_version}
    docker container cp mysql-connector-java-8.0.20.jar bitbucket:/var/atlassian/application-data/bitbucket/lib/mysql-connector-java-8.0.20.jar
    rm mysql-connector-java-8.0.20.jar
}

#######################################
# Initialize bitbucket database. Requires a database service to be running.
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
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX on bitbucketdb.* TO 'bitbucket_user'@'%' IDENTIFIED BY 'bitbucket_password'; \
        flush privileges;"
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
    install_docker
    setup_openshift_cluster
    download_tailor
    print_system_setup
    startup_atlassian_mysql
    startup_atlassian_jira
    startup_atlassian_bitbucket
}

# the next line will make bash try to execute the script arguments in the context of this script,
# thus supporting syntax like this:
# bash deployments.sh install_docker
# bash is used here to start a subshell in case there is an exit command in a function to not to
# kill the parent shell from where the script is getting called.
"$@"
