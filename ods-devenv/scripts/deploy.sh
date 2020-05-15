#!/usr/bin/env bash

set -eu

atlassian_mysql_container_name=atlassian_mysql
atlassian_mysql_port=3306
atlassian_mysql_version=5.7
atlassian_jira_container_name=jira
atlassian_jira_db_name=jiradb
atlassian_jira_software_version=8.5.3
atlassian_jira_ip=
atlassian_jira_port=18080
atlassian_bitbucket_container_name=bitbucket
atlassian_bitbucket_db_name=bitbucketdb
atlassian_bitbucket_version=6.8.2-jdk11
atlassian_bitbucket_ip=
atlassian_bitbucket_port=28080

# TODO add global openshift_user, openshift_password and use them when creating ods-core.env for improved configurability
# TODO drop global openshift_route and pull openshift_route from OpenShift where needed
openshift_route=172.17.0.1

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
    echo "alias lsop='sudo lsof +c 15 -nP -iTCP -sTCP:LISTEN" >> ~/.bashrc

    # remove obsolete version of git
    if [[ ! -z $(command -v git) ]]; then sudo yum remove -y git*; fi
    sudo yum update -y
    sudo yum install -y yum-utils epel-release https://centos7.iuscommunity.org/ius-release.rpm
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
        -v /home/${USER}/mysql_data:/var/lib/mysql mysql:${atlassian_mysql_version} --default-storage-engine=INNODB \
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
        --name ${atlassian_jira_container_name} \
        -v $HOME/jira_data:/var/atlassian/application-data/jira \
        -dp ${atlassian_jira_port}:8080 \
        -e "ATL_JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_jira_db_name}" \
        -e ATL_JDBC_USER=jira_user \
        -e ATL_JDBC_PASSWORD=jira_password \
        -e ATL_DB_DRIVER=com.mysql.jdbc.Driver \
        -e ATL_DB_TYPE=mysql \
        -e ATL_DB_SCHEMA_NAME= \
        atlassian/jira-software:${atlassian_jira_software_version}
    local jira_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_jira_container_name})
    echo "Atlassian jira-software is listening on ${jira_ip}:${atlassian_jira_port}"
    # this race condition normally works out. Did not cause any trouble yet.
    # Alternative approach: start container, stop container, cp driver, restart container ...
    docker container cp mysql-connector-java-8.0.20.jar jira:/opt/atlassian/jira/lib/
    rm mysql-connector-java-8.0.20.jar
    inspect_jira_ip
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
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX,CREATE TEMPORARY TABLES on jiradb.* TO 'jira_user'@'%' IDENTIFIED BY 'jira_password'; \
        flush privileges;"
}

#######################################
# Overwrites existing jiradb data files with a backup from a fresh jiradb incl
# timebomb licenses.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restore_atlassian_jiradb_with_license() {
    local target_dir=/home/${USER}/mysql_data
    sudo rm -rf ${target_dir}/jiradb
    sudo tar xzf ${BASH_SOURCE%/*}/../atlassian/jiradb.tar.gz -C ${target_dir}/..
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
        --name ${atlassian_bitbucket_container_name} \
        -v ${HOME}/bitbucket_data:/var/atlassian/application-data/bitbucket \
        -dp ${atlassian_bitbucket_port}:7990 \
        -e "JDBC_URL=jdbc:mysql://${mysql_ip}:${atlassian_mysql_port}/${atlassian_bitbucket_db_name}" \
        -e JDBC_DRIVER=com.mysql.jdbc.Driver \
        -e JDBC_USER=bitbucket_user \
        -e JDBC_PASSWORD=bitbucket_password \
        atlassian/bitbucket-server:${atlassian_bitbucket_version}
    local bitbucket_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_bitbucket_container_name})
    echo "Atlassian BitBucket is listening on ${bitbucket_ip}:${atlassian_bitbucket_port}"
    docker container exec bitbucket bash -c "mkdir -p /var/atlassian/application-data/bitbucket/lib; chown bitbucket:bitbucket /var/atlassian/application-data/bitbucket/lib"
    docker container cp mysql-connector-java-8.0.20.jar bitbucket:/var/atlassian/application-data/bitbucket/lib/mysql-connector-java-8.0.20.jar
    rm mysql-connector-java-8.0.20.jar
    inspect_bitbucket_ip
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
        GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,REFERENCES,ALTER,INDEX,CREATE TEMPORARY TABLES on bitbucketdb.* TO 'bitbucket_user'@'%' IDENTIFIED BY 'bitbucket_password'; \
        flush privileges;"
}

#######################################
# Overwrites existing bitbucketdb data files with a backup from a fresh bitbucketdb incl
# timebomb licenses.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restore_atlassian_bitbucketdb_with_license() {
    local target_dir=/home/${USER}/mysql_data
    sudo rm -rf ${target_dir}/bitbucketdb
    sudo tar xzf ${BASH_SOURCE%/*}/../atlassian/bitbucketdb.tar.gz -C ${target_dir}/..
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
    if [[ -z $(curl -sX GET --user openshift:openshift http://${openshift_route}:${atlassian_bitbucket_port}/rest/api/1.0/projects | jq '.values[] | select(.key=="OPENDEVSTACK") | .key ') ]]; then
        echo "Creating project opendevstack in BitBucket"
        curl -X POST --user openshift:openshift http://${openshift_route}:${atlassian_bitbucket_port}/rest/api/1.0/projects \
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
        echo "Creating repository ${repository} on http://${openshift_route}:${atlassian_bitbucket_port}."
        curl -X POST --user openshift:openshift http://${openshift_route}:${atlassian_bitbucket_port}/rest/api/1.0/projects/opendevstack/repos \
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
        echo "Deleting repository opendevstack/${repository} on http://${openshift_route}:${atlassian_bitbucket_port}."
        curl -X DELETE --user openshift:openshift http://${openshift_route}:${atlassian_bitbucket_port}/rest/api/1.0/projects/opendevstack/repos/${repository}
    done
}

#######################################
# For each of the listed names this function will delete the corresponding
# repository in the local BitBucket instance in the opendevstack project
# Globals:
#   atlassian_bitbucket_port
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function initialise_ods_repositories() {
    local opendevstack_dir="/home/${USER}/opendevstack"
    local current_dir="$(pwd)"
    mkdir -p "${opendevstack_dir}"
    cd "${opendevstack_dir}"

    # curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/master/ods-setup/repos.sh
    curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/feature/ods-devenv/ods-setup/repos.sh
    chmod u+x ./repos.sh
    ./repos.sh --sync --bitbucket http://openshift:openshift@${openshift_route}:${atlassian_bitbucket_port} --git-ref master --confirm
}

function inspect_bitbucket_ip() {
    atlassian_bitbucket_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_bitbucket_container_name})
}

function inspect_jira_ip() {
    atlassian_jira_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_jira_container_name})
}

#######################################
# Creates a config file and uploads it into ods-configuration repository on
# the local BitBucket instance.
# Globals:
#   atlassian_bitbucket_ip
#   atlassian_bitbucket_port
#   atlassian_jira_ip
#   atlassian_jira_port
#   openshift_route
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function create_configuration() {
    ods-setup/config.sh --verbose
    pushd ../ods-configuration
    git init
    echo "ods-core.env.sample" > .gitignore

    if [[ -z ${atlassian_bitbucket_ip} ]]; then
        # can happen if script functions are called selectively
        inspect_bitbucket_ip
    fi
    if [[ -z ${atlassian_jira_ip} ]]; then
        # can happen if script functions are called selectively
        inspect_jira_ip
    fi

    if ! git remote | grep origin; then
        git remote add origin http://openshift:openshift@${openshift_route}:${atlassian_bitbucket_port}/scm/opendevstack/ods-configuration.git
    fi
    git add -- .
    git commit -m "initial commit"
    git push --set-upstream origin master
    # base64('changeit') -> Y2hhbmdlbWUK
    # base64('openshift') -> b3BlbnNoaWZ0Cg==
    sed -i "s/cd.192.168.56.101.nip.io/ods.${openshift_route}.nip.io/" ods-core.env
    sed -i "s|JIRA_URL=http://192.168.56.31:8080|JIRA_URL=http://${atlassian_jira_ip}:${atlassian_jira_port}|" ods-core.env
    sed -i "s|BITBUCKET_HOST=192.168.56.31:7990|BITBUCKET_HOST=${atlassian_bitbucket_ip}:${atlassian_bitbucket_port}|" ods-core.env
    sed -i "s|BITBUCKET_URL=http://192.168.56.31:7990|BITBUCKET_URL=http://${atlassian_bitbucket_ip}:${atlassian_bitbucket_port}|" ods-core.env
    sed -i "s|REPO_BASE=http://192.168.56.31:7990/scm|REPO_BASE=http://${atlassian_bitbucket_ip}:${atlassian_bitbucket_port}/scm|" ods-core.env

    sed -i "s|CD_USER_ID=.*$|CD_USER_ID=openshift|" ods-core.env
    sed -i "s|CD_USER_ID_B64=.*$|CD_USER_ID_B64=b3BlbnNoaWZ0Cg==|" ods-core.env
    sed -i "s|CD_USER_PWD_B64=.*$|CD_USER_PWD_B64=b3BlbnNoaWZ0Cg==|" ods-core.env

    sed -i "s|NEXUS_USERNAME=.*$|NEXUS_USERNAME=openshift|" ods-core.env
    sed -i "s|NEXUS_PASSWORD=.*$|NEXUS_PASSWORD=openshift|" ods-core.env
    sed -i "s|NEXUS_PASSWORD_B64=.*$|NEXUS_PASSWORD_B64=$(echo openshift | base64)|" ods-core.env
    sed -i "s|NEXUS_AUTH=.*$|NEXUS_AUTH=openshift:openshift|" ods-core.env

    sed -i "s|SONARQUBE_HOST=.*$|SONARQUBE_HOST=sonarqube-ods.${openshift_route}.nip.nio|" ods-core.env
    sed -i "s|SONARQUBE_URL=.*$|SONARQUBE_URL=https://sonarqube-ods.${openshift_route}.nip.nio|" ods-core.env
    sed -i "s|SONAR_ADMIN_USERNAME=.*$|SONAR_ADMIN_USERNAME=openshift|" ods-core.env
    sed -i "s|SONAR_ADMIN_PASSWORD_B64=.*$|SONAR_ADMIN_PASSWORD_B64=$(echo openshift | base64)|" ods-core.env
    sed -i "s|SONAR_DATABASE_PASSWORD_B64=.*$|SONAR_DATABASE_PASSWORD_B64=$(echo sonarqube | base64)|" ods-core.env

    sed -i "s|IDP_DNS=[.0-9a-z]*$|IDP_DNS=|" ods-core.env
    sed -i "s/192.168.56.101/${openshift_route}/" ods-core.env
    # change sonarqube admin password?
    git add -- .
    git commit -m "updated config for EDP box"
    git push
    popd
}

function install_ods_project() {
    ods-setup/setup-ods-project.sh --namespace ods --reveal-secrets --verbose --non-interactive
}

#######################################
# Sets up Nexus as a service OpenShift.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_nexus() {
    make install-nexus # TODO call script directly to make call to tailor non-interactive
    local nexus_url="https://$(oc -n ods get route nexus3 -ojsonpath={.spec.host})"
    pushd nexus
    ./configure.sh --namespace ods --nexus=${nexus_url} --insecure --verbose
    popd
}

#######################################
# Sets up SonarQube as a service OpenShift.
# Globals:
#   NAMESPACE (e.g. ods)
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_sonarqube() {
    echo "Setting up SonarQube"

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
    ./configure.sh --sonarqube=${SONARQUBE_URL} --verbose --insecure
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
    # TODO wait until mysql becomes available
    initialize_atlassian_jiradb
    restore_atlassian_jiradb_with_license
    startup_atlassian_jira
    initialize_atlassian_bitbucketdb
    restore_atlassian_bitbucketdb_with_license
    startup_atlassian_bitbucket
    # TODO wait until BitBucket becomes available
    create_empty_ods_repositories
    initialise_ods_repositories

    create_configuration
    install_ods_project
    setup_nexus

}

# the next line will make bash try to execute the script arguments in the context of this script,
# thus supporting syntax like this:
# bash deployments.sh install_docker
# bash is used here to start a subshell in case there is an exit command in a function to not to
# kill the parent shell from where the script is getting called.
"$@"
