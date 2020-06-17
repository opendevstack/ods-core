#!/usr/bin/env bash

set -eu

odsbox_domain=odsbox.lan

atlassian_mysql_container_name=atlassian_mysql
atlassian_mysql_ip=
atlassian_mysql_port=3306
atlassian_mysql_version=5.7
atlassian_crowd_software_version=3.7.0
atlassian_crowd_container_name=crowd
atlassian_crowd_port=48080
atlassian_crowd_port_internal=8095
atlassian_crowd_host="crowd.${odsbox_domain}"
atlassian_crowd_ip=
atlassian_jira_container_name=jira
atlassian_jira_db_name=jiradb
atlassian_jira_host="jira.${odsbox_domain}"
atlassian_jira_ip=
atlassian_jira_port=18080
atlassian_jira_software_version=8.5.3
# docker network internal jira port
atlassian_jira_port_internal=8080
atlassian_bitbucket_ip=
atlassian_bitbucket_container_name=bitbucket
atlassian_bitbucket_db_name=bitbucketdb
atlassian_bitbucket_host="bitbucket.${odsbox_domain}"
atlassian_bitbucket_version=6.8.2-jdk11
atlassian_bitbucket_port=28080
# docker network internal bitbucket port
atlassian_bitbucket_port_internal=7990
# Backup files
atlassian_mysql_dump_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/mysql_data.tar.gz
atlassian_jira_backup_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/jira_data.tar.gz
atlassian_bitbucket_backup_url=https://bi-ods-dev-env.s3.eu-central-1.amazonaws.com/atlassian_files/bitbucket_data.tar.gz

# git ref to build ods box against
ods_git_ref=

# TODO add global openshift_user, openshift_password and use them when creating ods-core.env for improved configurability

# Will be used in oc cluster up as --public-hostname and part of the --routing-suffix
# TODO make this value configurable, can then be set e.g. by bootstrap script or other clients
# TODO fix: hostname -i fails after dnsmasq dns service is configured. The network interface will have different names on various platforms, like eth0, ens33, etc.
# for now, making a best bet on the applicable ip adress with: hostname -I | awk '{print $1}'
public_hostname=$(hostname -I | awk '{print $1}')
echo "OpenShift ip will be ${public_hostname}"

NAMESPACE=ods

function display_usage() {
    echo
    echo "This script provides functions to install and configure various parts of an EDP/ODS installation."
    echo "The first argument to this script must always be the ods git ref to build against, e.g. master or feature/ods-devenv."
    echo "Functions in this script can be called like in the sample calls below:"
    echo "deploy.sh feature/ods-devenv display_usage"
    echo "deploy.sh feature/ods-devenv install_docker"
    echo "deploy.sh feature/ods-devenv startup_atlassian_bitbucket"
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
    mkdir -p "${HOME}/tmp"
    # print warning if hypervisor application support is not activated - interesting for local VMWare VMs
    if ! grep -q vmx /proc/cpuinfo
    then
        echo "WARNING: The VM needs to be configured to enable hypervisor applications."
        echo "If you are on an AWS ECS instance you can ignore this warning."
    fi

{
    echo "alias ll='ls -AFhl --color=auto'"
    echo "alias dcip='docker inspect --format \"{{.NetworkSettings.IPAddress}}\"'"
    echo "alias lsop='sudo lsof +c 15 -nP -iTCP -sTCP:LISTEN'"
} >> ~/.bashrc

    # suppress sudo timeout
    sudo sed -i "\$aDefaults    env_reset,timestamp_timeout=-1" /etc/sudoers

    # remove obsolete version of git
    if [[ -n $(command -v git) ]]; then sudo yum remove -y git*; fi
    sudo yum update -y
    sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
    sudo yum -y install firewalld git2u-all glances golang jq tree
    go get github.com/ericchiang/pup
    mv "${HOME}/go/bin/pup" "${HOME}/bin/"

    if ! systemctl status firewalld | grep -i running; then
        systemctl start firewalld
    fi

    git config --global user.email "openshift@odsbox.lan"
    git config --global user.name "OpenShift"
}

#######################################
# To facilitate maintainability of services running in EDP in a box, it is
# mandatory to be able to refer to services using names, for which a
# nameservice is required.
# Call this function before starting the OpenShift cluster so OpenShift
# will find the local dns server in /etc/resolv.conf.
#
# TODO verify that dnsmasq will respond to services added to /etc/hosts
# dynamically or else restart dnsmasq after Atlassian suite has be setup.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_dnsmasq() {
    echo "Setting up dnsmasq DNS service"
    local dnsmasq_conf_path
    dnsmasq_conf_path="/etc/dnsmasq.conf"

    # tear down old running dnsmasq instances
    local job_id
    for job_id in $(ps -ef | grep dnsmasq | grep -v grep | grep -v setup_dnsmasq | awk -v col=2 '{print $2}')
    do
        sudo kill -9 "${job_id}" || true
    done

    sudo yum install dnsmasq
    sudo systemctl start dnsmasq
    sleep 10
    if ! sudo systemctl status dnsmasq | grep -q active
    then
        echo "dnsmasq startup appears to have failed."
        exit
    else
        echo "dnsmasq service up and running"
    fi

    # if script runs for the 2nd time on a machine, backup dnsmasq.conf from orig
    if [[ -f "${dnsmasq_conf_path}.orig" ]]
    then
        sudo cp "${dnsmasq_conf_path}.orig" "${dnsmasq_conf_path}"
    else
        sudo cp "${dnsmasq_conf_path}" "${dnsmasq_conf_path}.orig"
    fi

    sudo sed -i "s|#domain-needed|domain-needed|" "${dnsmasq_conf_path}"
    sudo sed -i "s|#bogus-priv|bogus-priv|" "${dnsmasq_conf_path}"
    # might also want to add 172.31.0.2 as forward name server
    # sudo sed -i "/#server=\/localnet\/192.168.0.1/a server=172.31.0.2\nserver=8.8.8.8\nserver=8.8.4.4" "${dnsmasq_conf_path}"
    sudo sed -i "/#server=\/localnet\/192.168.0.1/a server=8.8.8.8\nserver=8.8.4.4" "${dnsmasq_conf_path}"
    sudo sed -i "/#address=\/double-click.net\/127.0.0.1/a address=\/odsbox.lan\/${public_hostname}\naddress=\/odsbox.lan\/172.17.0.1\naddress=\/odsbox.lan\/127.0.0.1" "${dnsmasq_conf_path}"
    sudo sed -i "s|#listen-address=.*$|listen-address=::1,127.0.0.1,${public_hostname}|" "${dnsmasq_conf_path}"
    sudo sed -i "s|#domain=thekelleys.org.uk|domain=odsbox.lan|" "${dnsmasq_conf_path}"

    # dnsmasq logs on stderr (?!)
    if !  2>&1 dnsmasq --test | grep -q "dnsmasq: syntax check OK."
    then
        echo "dnsmasq configuration failed. Please check ${dnsmasq_conf_path} and compare with ${dnsmasq_conf_path}.orig"
    else
        echo "dnsmasq is ok with configuration changes."
    fi

    sudo chattr -i /etc/resolv.conf
    sudo sed -i "s|nameserver .*$|nameserver ${public_hostname}|" /etc/resolv.conf
    # TODO there must be a better way ...
    sudo chattr +i /etc/resolv.conf
    sudo systemctl restart dnsmasq.service
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
# Sets up the docker daemon and configures insecure registries.
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
            "172.30.0.0/16",
            "docker-registry-default.ocp.odsbox.lan"
        ]
    }
EOF
    sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker.service

    echo "Configuring firewall for docker containers:"
    sudo firewall-cmd --permanent --new-zone dockerc
    sudo firewall-cmd --permanent --zone dockerc --add-source 172.17.0.0/16
    sudo firewall-cmd --permanent --zone dockerc --add-port 8443/tcp
    sudo firewall-cmd --permanent --zone dockerc --add-port 53/udp
    sudo firewall-cmd --permanent --zone dockerc --add-port 8053/udp
    sudo firewall-cmd --reload
}

# checks whether cluster runs and if so shuts it down
function shutdown_openshift_cluster() {
    # TODO check if cluster is running and if so shut it down
    oc cluster down
}

function startup_openshift_cluster() {
    local ip_address
    ip_address="${public_hostname}"
    local cluster_dir
    cluster_dir="${HOME}/openshift.local.clusterup"

    register_dns ocp.odsbox.lan "${ip_address}"
    oc cluster up --base-dir="${cluster_dir}" --insecure-skip-tls-verify=true --routing-suffix "ocp.odsbox.lan" --public-hostname "ocp.odsbox.lan"

    oc login -u system:admin
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
    # ip_address=172.17.0.1
    local ip_address
    ip_address="${public_hostname}"

    startup_openshift_cluster

    local cluster_dir
    cluster_dir="${HOME}/openshift.local.clusterup"

    echo -e "Create and replace old router cert"
    oc project default
    oc get --export secret -o yaml router-certs > "${HOME}/old-router-certs-secret.yaml"
    oc adm ca create-server-cert --signer-cert="${cluster_dir}/kube-apiserver/ca.crt" --signer-key="${cluster_dir}/kube-apiserver/ca.key" --signer-serial="${cluster_dir}/kube-apiserver/ca.serial.txt" --hostnames="kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.default.svc.cluster.local,localhost,openshift,openshift.default,openshift.default.svc,openshift.default.svc.cluster,openshift.default.svc.cluster.local,127.0.0.1,172.17.0.1,172.30.0.1,*.ocp.odsbox.lan,ocp.odsbox.lan,*.router.default.svc.cluster.local,router.default.svc.cluster.local" --cert=router.crt --key=router.key
    cat router.crt "${cluster_dir}/kube-apiserver/ca.crt" router.key > router.pem
    oc create secret tls router-certs --cert=router.pem --key=router.key -o json --dry-run | oc replace -f -
    oc annotate service router service.alpha.openshift.io/serving-cert-secret-name- service.alpha.openshift.io/serving-cert-signed-by-
    oc annotate service router service.alpha.openshift.io/serving-cert-secret-name=router-certs

    # wait for oc rollout to return 0
    echo -n "Waiting for OpenShift router to become available"
    while true
    do
        if oc rollout latest dc/router
        then
            break
        fi
        echo -n "."
        sleep 10
    done
    echo -n "available!"; echo

    echo "Expose registry route"
    oc create route edge --service=docker-registry --hostname="docker-registry-default.ocp.odsbox.lan" -n default

    oc adm policy add-cluster-role-to-user cluster-admin developer
    # allow for OpenShifts to be resolved within OpenShift network
    sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT

    # TODO create a test project to verify cluster works, remove after development phase
    oc project myproject
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
    curl -LO "https://github.com/opendevstack/tailor/releases/download/v1.1.0/tailor-linux-amd64"
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
        rm -rf "/home/${USER:?}/${data_file:?}"
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
        -v "/home/${USER}/mysql_data:/var/lib/mysql" "mysql:${atlassian_mysql_version}" --default-storage-engine=INNODB \
        --character-set-server=utf8 \
        --collation-server=utf8_bin \
        --default-storage-engine=INNODB \
        --innodb-default-row-format=DYNAMIC \
        --innodb-large-prefix=ON \
        --innodb-file-format=Barracuda \
        --innodb-log-file-size=2G \
        > "${HOME}/tmp/mysql_docker_download.log" 2>&1 # reduce noise in log output from docker image download
    local mysql_ip
    mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
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
# When Jira and Crowd both are up and running, this function can be used
# to configure a Jira directory service against Crowd.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function configure_jira2crowd() {
    local cookie_jar_path
    cookie_jar_path="${HOME}/tmp/jira_cookie_jar.txt"
    echo "Configure Jira against Crowd directory ..."
    # login to Jira
    curl 'http://172.17.0.1:18080/login.jsp' \
        -b "${cookie_jar_path}" \
        -c "${cookie_jar_path}" \
        --data 'os_username=openshift&os_password=openshift&os_destination=&user_role=&atl_token=&login=Log+In' \
        --compressed \
        --insecure --silent --location -o /dev/null
    echo "Logged into Jira"

    # setting atl_token
    atl_token=$(curl 'http://172.17.0.1:18080/plugins/servlet/embedded-crowd/configure/new/' \
        -b /home/openshift/tmp/jira_cookie_jar.txt \
        -c /home/openshift/tmp/jira_cookie_jar.txt \
        --data "newDirectoryType=CROWD&next=Next" \
        --compressed \
        --insecure --location --silent | pup 'input[name="atl_token"] attr{value}')
    echo "Retrieved Jira xsrf atl_token ${atl_token}."

    # WebSudo authentication - sign in as admin
    curl 'http://172.17.0.1:18080/secure/admin/WebSudoAuthenticate.jspa' \
        -b /home/openshift/tmp/jira_cookie_jar.txt \
        -c /home/openshift/tmp/jira_cookie_jar.txt \
        --data "webSudoPassword=openshift&webSudoDestination=%2Fsecure%2Fadmin%2FViewApplicationProperties.jspa&webSudoIsPost=false&atl_token=${atl_token}" \
        --compressed \
        --insecure --location -o /dev/null # | pup --color

    # send crowd config data
    local crowd_service_name
    crowd_service_name="crowd.odsbox.lan"
    echo "Assuming crowd service to listen at ${crowd_service_name}:8095"
    local crowd_directory_id
    crowd_directory_id=$(curl 'http://172.17.0.1:18080/plugins/servlet/embedded-crowd/configure/crowd/' \
        -b /home/openshift/tmp/jira_cookie_jar.txt \
        -c /home/openshift/tmp/jira_cookie_jar.txt \
        --data "name=Crowd+Server&crowdServerUrl=http%3A%2F%2F${crowd_service_name}%3A8095%2Fcrowd%2F&applicationName=jira&applicationPassword=openshift&httpTimeout=&httpMaxConnections=&httpProxyHost=&httpProxyPort=&httpProxyUsername=&httpProxyPassword=&crowdPermissionOption=READ_ONLY&_nestedGroupsEnabled=visible&incrementalSyncEnabled=true&_incrementalSyncEnabled=visible&groupSyncOnAuthMode=ALWAYS&crowdServerSynchroniseIntervalInMin=60&save=Save+and+Test&atl_token=${atl_token}&directoryId=0" \
        --compressed \
        --insecure \
        --location \
        | pup 'table#directory-list tbody tr:nth-child(even) td.id-column text{}' \
        | tr -d "[:space:]")

    # sync bitbucket with crowd directory
    curl "http://172.17.0.1:18080/plugins/servlet/embedded-crowd/directories/sync?directoryId=${crowd_directory_id}&atl_token=${atl_token}" \
        -b "${cookie_jar_path}" \
        -c "${cookie_jar_path}" \
        --compressed \
        --insecure --silent -o /dev/null
    echo "Synced Jira directory with Crowd."
    rm "${cookie_jar_path}"
}

#######################################
# When BitBucket and Crowd both are up and running, this function can be used
# to configure a BitBucket directory service against Crowd.
# Globals:
#   n/a
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function configure_bitbucket2crowd() {
    local cookie_jar_path
    cookie_jar_path="${HOME}/tmp/bitbucket_cookie_jar.txt"
    echo "Configure BitBucket against Crowd directory ..."
    # login to BitBucket
    curl 'http://172.17.0.1:28080/j_atl_security_check' \
        -b "${cookie_jar_path}" \
        -c "${cookie_jar_path}" \
        --data 'j_username=openshift&j_password=openshift&_atl_remember_me=on&submit=Log+in' \
        --compressed \
        --insecure --silent -o /dev/null
    echo "Logged into BitBucket"

    # request crowd config form
    local atl_token
    atl_token=$(curl 'http://172.17.0.1:28080/plugins/servlet/embedded-crowd/configure/new/' \
        -b "${cookie_jar_path}" \
        -c "${cookie_jar_path}" \
        --data 'newDirectoryType=CROWD&next=Next' \
        --compressed \
        --insecure -w '%{http_code}' --location --silent | pup 'input[name="atl_token"] attr{value}')
    echo "Retrieved BitBucket xsrf atl_token ${atl_token}."

    # send crowd config data
    local crowd_service_name
    crowd_service_name="crowd.odsbox.lan"
    echo "Assuming crowd service to listen at ${crowd_service_name}:8095"
    local crowd_directory_id
    crowd_directory_id=$(curl 'http://172.17.0.1:28080/plugins/servlet/embedded-crowd/configure/crowd/' \
        -b /home/openshift/tmp/bitbucket_cookie_jar.txt \
        -c /home/openshift/tmp/bitbucket_cookie_jar.txt \
        --data "name=Crowd+Server&crowdServerUrl=http%3A%2F%2F${crowd_service_name}%3A8095%2Fcrowd&applicationName=bitbucket&applicationPassword=openshift&httpTimeout=&httpMaxConnections=&httpProxyHost=&httpProxyPort=&httpProxyUsername=&httpProxyPassword=&crowdPermissionOption=READ_ONLY&_nestedGroupsEnabled=visible&incrementalSyncEnabled=true&_incrementalSyncEnabled=visible&groupSyncOnAuthMode=ALWAYS&crowdServerSynchroniseIntervalInMin=60&save=Save+and+Test&atl_token=${atl_token}&directoryId=0" \
        --compressed \
        --insecure --location --silent \
        | pup 'table#directory-list tbody tr:nth-child(even) td.id-column text{}' \
        | tr -d "[:space:]")
    echo "Configured Crowd directory on BitBucket, got crowd directory id ${crowd_directory_id}."

    # sync bitbucket with crowd directory
    curl "http://172.17.0.1:28080/plugins/servlet/embedded-crowd/directories/sync?directoryId=${crowd_directory_id}&atl_token=${atl_token}" \
        -b "${cookie_jar_path}" \
        -c "${cookie_jar_path}" \
        --compressed \
        --insecure --silent -o /dev/null
    echo "Synced BitBucket directory with Crowd."
    rm "${cookie_jar_path}"
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
    local mysql_ip
    mysql_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})

    echo "Downloading mysql-connector-java"
    local download_dir="downloads_jira"
    local download_url="https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar"
    local db_driver_file="mysql-connector-java-8.0.20.jar"
    download_file_to_folder "${download_url}" "${download_dir}"

    pushd ods-devenv/jira-docker
    cp Dockerfile.template Dockerfile
    sed -i "s|__version__|${atlassian_jira_software_version}|g" Dockerfile
    sed -i "s|__base-image__|jira-software|g" Dockerfile
    docker image build --build-arg APP_DNS="docker-registry-default.ocp.odsbox.lan" -t ods-jira-docker:latest .
    popd

    docker container run \
        --name ${atlassian_jira_container_name} \
        -v "$HOME/jira_data:/var/atlassian/application-data/jira" \
        -dp ${atlassian_jira_port}:8080 \
        -e "ATL_JDBC_URL=jdbc:mysql://${atlassian_mysql_container_name}.${odsbox_domain}:${atlassian_mysql_port}/${atlassian_jira_db_name}" \
        -e ATL_JDBC_USER=jira_user \
        -e ATL_JDBC_PASSWORD=jira_password \
        -e ATL_DB_DRIVER=com.mysql.jdbc.Driver \
        -e ATL_DB_TYPE=mysql \
        -e ATL_DB_SCHEMA_NAME= \
        ods-jira-docker:latest \
        > "${HOME}/tmp/jira_docker_download.log" 2>&1 # reduce noise in log output from docker image download

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
    echo "Atlassian jira-software is listening on ${atlassian_jira_host}, ${atlassian_jira_ip}:${atlassian_jira_port_internal} and ${public_hostname}:${atlassian_jira_port}"
    echo -n "Configuring /etc/hosts with jira ip by "
    if grep -q jira < /etc/hosts
    then
        echo "replacing the previous value."
        sudo sed -i "s|^.*jira.odsbox.lan|${atlassian_jira_ip}    jira.odsbox.lan|" /etc/hosts
    else
        echo "appending the new value... ${atlassian_jira_ip}    jira.odsbox.lan"
        echo "${atlassian_jira_ip}    jira.odsbox.lan" | sudo tee -a /etc/hosts
    fi
    echo
}

function prepare_jira_container() {
    local download_dir="${1:?null}"
    docker container cp "${download_dir}/mysql-connector-java-8.0.20.jar" jira:/opt/atlassian/jira/lib/
    docker container exec -i jira bash -c "sed -i \"s|172.17.0.6|${atlassian_mysql_container_name}.${odsbox_domain}|\" dbconfig.xml"
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
    docker cp "${BASH_SOURCE%/*}/crowd-provision-app-backup.xml" crowd:/var/atlassian/application-data/crowd/shared/

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
    # cleanup
    rm crowd_sessionid_cookie.txt

    inspect_crowd_ip
    echo -n "Configuring /etc/hosts with crowd ip by "
    if grep -q crowd < /etc/hosts
    then
        echo "replacing the previous value."
        sudo sed -i "s|^.*crowd.odsbox.lan|${atlassian_crowd_ip}    crowd.odsbox.lan|" /etc/hosts
    else
        echo "appending the new value... "
        echo "${atlassian_crowd_ip}    crowd.odsbox.lan" | sudo tee -a /etc/hosts
    fi
    echo
    echo "Atlassian Crowd installation is done and server listening on ${atlassian_crowd_host}:${atlassian_crowd_port_internal}, http://${atlassian_crowd_ip}:${atlassian_crowd_port_internal} and ${public_hostname}:${atlassian_crowd_port}"
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
    echo "To copy from 'crowd' container the backup file to local folder:"
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
    local mysql_ip
    mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Setting up jiradb on ${mysql_ip}:${atlassian_mysql_port}."
    echo "jiradbrpwd" | docker container run -i --rm mysql:${atlassian_mysql_version} mysql -h "${mysql_ip}" -u root -p -e \
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
    local mysql_ip
    mysql_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})

    echo "Downloading mysql-connector-java"
    local download_dir="downloads_bitbucket"
    local download_url="https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar"
    local db_driver_file="mysql-connector-java-8.0.20.jar"
    download_file_to_folder "${download_url}" "${download_dir}"

    pushd ods-devenv/bitbucket-docker
    cp Dockerfile.template Dockerfile
    sed -i "s|__version__|${atlassian_bitbucket_version}|g" Dockerfile
    sed -i "s|__base-image__|bitbucket-server|g" Dockerfile
    docker image build --build-arg APP_DNS="docker-registry-default.ocp.odsbox.lan" -t ods-bitbucket-docker:latest .
    popd

    local

    docker container run \
        --name ${atlassian_bitbucket_container_name} \
        --health-cmd '[ ! -z $(curl -X GET --user openshift:openshift http://localhost:7990/rest/api/1.0/projects) ]' \
        -v "${HOME}/bitbucket_data:/var/atlassian/application-data/bitbucket" \
        -dp ${atlassian_bitbucket_port}:7990 \
        -e "JDBC_URL=jdbc:mysql://${atlassian_mysql_container_name}.${odsbox_domain}:${atlassian_mysql_port}/${atlassian_bitbucket_db_name}" \
        -e JDBC_DRIVER=com.mysql.jdbc.Driver \
        -e JDBC_USER=bitbucket_user \
        -e JDBC_PASSWORD=bitbucket_password \
        ods-bitbucket-docker:latest \
        > "${HOME}/tmp/bitbucket_docker_download.log" 2>&1 # reduce noise in log output from docker image download

    docker container exec bitbucket bash -c "mkdir -p /var/atlassian/application-data/bitbucket/lib; chown bitbucket:bitbucket /var/atlassian/application-data/bitbucket/lib"
    docker container cp "${download_dir}/${db_driver_file}" bitbucket:/var/atlassian/application-data/bitbucket/lib/mysql-connector-java-8.0.20.jar
    rm -rf "${download_dir}"
    inspect_bitbucket_ip
    echo "Atlassian BitBucket is listening on ${atlassian_bitbucket_host}, ${atlassian_bitbucket_ip}:${atlassian_bitbucket_port_internal} and ${public_hostname}:${atlassian_bitbucket_port}"
    echo -n "Configuring /etc/hosts with bitbucket ip by "
    if grep -q bitbucket < /etc/hosts
    then
        echo "replacing the previous value."
        sudo sed -i "s|^.*bitbucket.odsbox.lan|${atlassian_bitbucket_ip}    bitbucket.odsbox.lan|" /etc/hosts
    else
        echo "appending the new value... "
        echo "${atlassian_bitbucket_ip}    bitbucket.odsbox.lan" | sudo tee -a /etc/hosts
    fi
    echo
}

#######################################
# Restart bitbucket.
# Will register new container ip with /etc/hosts for dns resolution
# Globals:
#   atlassian_bitbucket_container_name
#   atlassian_bitbucket_ip
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restart_atlassian_bitbucket() {
    echo "Restarting BitBucket..."
    # restart the container
    docker container restart "${atlassian_bitbucket_container_name}"
    # find new ip if changed
    inspect_bitbucket_ip
    echo "New BitBucket container got ip ${atlassian_bitbucket_ip}. Registering with dns svc..."
    register_dns "${atlassian_bitbucket_container_name}" "${atlassian_bitbucket_ip}"
}

function restart_atlassian_mysql() {
    echo "Restarting MySQL..."
    # restart the container
    docker container restart "${atlassian_mysql_container_name}"
    # find new ip if changed
    inspect_mysql_ip
    echo "New MySQL container got ip ${atlassian_mysql_ip}. Registering with dns svc..."
    register_dns "${atlassian_mysql_container_name}" "${atlassian_mysql_ip}"
}

#######################################
# Restart jira.
# Will register new container ip with /etc/hosts for dns resolution
# Globals:
#   atlassian_jira_container_name
#   atlassian_jira_ip
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restart_atlassian_jira() {
    echo "Restarting Jira..."
    # restart the container
    docker container restart "${atlassian_jira_container_name}"
    # find new ip if changed
    inspect_jira_ip
    echo "New Jira container got ip ${atlassian_jira_ip}. Registering with dns svc..."
    register_dns "${atlassian_jira_container_name}" "${atlassian_jira_ip}"
}

#######################################
# Restart jira.
# Will register new container ip with /etc/hosts for dns resolution
# Globals:
#   atlassian_jira_container_name
#   atlassian_jira_ip
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function restart_atlassian_crowd() {
    echo "Restarting Crowd...."
    # restart the container
    docker container restart "${atlassian_crowd_container_name}"
    # find new ip if changed
    inspect_crowd_ip
    echo "New Crowd container got ip ${atlassian_crowd_ip}. Registering with dns svc..."
    register_dns "${atlassian_crowd_container_name}" "${atlassian_crowd_ip}"
}

#######################################
# Register service name and ip with /etc/hosts for name resolution
# Globals:
#   n/a
# Arguments:
#   service_name - e.g. bitbucket. Will be expanded with domain odsbox.lan to bitbucket.odsbox.lan
#   ip - the new ip address for the service.
# Returns:
#   None
#######################################
function register_dns() {
    local service_name
    service_name=$1
    local ip
    ip=$2

    # register new ip with /etc/hosts
    echo -n "Configuring /etc/hosts with ${service_name} with ip ${ip} by "
    if grep -q "${service_name}" < /etc/hosts
    then
        echo "replacing the previous value with ${ip}    ${service_name}.odsbox.lan."
        sudo sed -i "s|^.*${service_name}.odsbox.lan|${ip}    ${service_name}.odsbox.lan|" /etc/hosts
    else
        echo "appending the new value ${ip}    ${service_name}.odsbox.lan."
        echo "${ip}    ${service_name}.odsbox.lan" | sudo tee -a /etc/hosts
    fi
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
    local mysql_ip
    mysql_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
    echo "Setting up bitbucket database on ${mysql_ip}:${atlassian_mysql_port}."
    echo "jiradbrpwd" | docker container run -i --rm mysql:${atlassian_mysql_version} mysql -h "${mysql_ip}" -u root -p -e \
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
    pushd ods-setup
    ./bitbucket.sh --insecure \
        --bitbucket "http://${public_hostname}:${atlassian_bitbucket_port}" \
        --user openshift \
        --password openshift \
        --ods-project opendevstack
    popd
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
    for repository in ods-core ods-quickstarters ods-jenkins-shared-library ods-provisioning-app ods-configuration ods-document-generation-templates; do
        echo "Deleting repository opendevstack/${repository} on http://${public_hostname}:${atlassian_bitbucket_port}."
        curl -X DELETE --user openshift:openshift "http://${public_hostname}:${atlassian_bitbucket_port}/rest/api/1.0/projects/opendevstack/repos/${repository}"
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
    curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/ods-setup/repos.sh
    chmod u+x ./repos.sh
    ./repos.sh --init --confirm --source-git-ref "${ods_git_ref}" --target-git-ref "${ods_git_ref}" --bitbucket "http://openshift:openshift@${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}" --verbose
    ./repos.sh --sync --bitbucket "http://openshift:openshift@${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}" --source-git-ref "${ods_git_ref}" --target-git-ref "${ods_git_ref}" --confirm
    popd
}

function inspect_bitbucket_ip() {
    atlassian_bitbucket_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${atlassian_bitbucket_container_name}")
}

function inspect_jira_ip() {
    atlassian_jira_ip=$(docker inspect -f '{{.NetworkSettings.IPAddress}}' "${atlassian_jira_container_name}")
}

function inspect_crowd_ip() {
    atlassian_crowd_ip=$(docker container inspect --format '{{.NetworkSettings.IPAddress}}' "${atlassian_crowd_container_name}")
}

function inspect_mysql_ip() {
    atlassian_mysql_ip=$(docker container inspect --format '{{.NetworkSettings.IPAddress}}' "${atlassian_mysql_container_name}")
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
    ods-setup/config.sh --verbose --bitbucket "http://openshift:openshift@${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}"
    pushd ../ods-configuration
    git init
    # keep ods-core.env.sample as a reference
    # echo "ods-core.env.sample" > .gitignore

    if ! git remote | grep origin; then
        git remote add origin "http://openshift:openshift@${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}/scm/opendevstack/ods-configuration.git"
    fi
    git add -- .
    git commit -m "initial commit"
    git push --set-upstream origin master
    # base64('changeit') -> Y2hhbmdlbWUK
    sed -i "s|ODS_GIT_REF=.*$|ODS_GIT_REF=${ods_git_ref}|" ods-core.env
    # changes the URLs and hostnames for Nexus, Sonarqube
    sed -i "s/cd.192.168.56.101.nip.io/ods.ocp.odsbox.lan/" ods-core.env
    sed -i "s|JIRA_URL=http://192.168.56.31:8080|JIRA_URL=http://${atlassian_jira_host}:${atlassian_jira_port_internal}|" ods-core.env
    sed -i "s|BITBUCKET_HOST=192.168.56.31:7990|BITBUCKET_HOST=${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}|" ods-core.env
    sed -i "s|BITBUCKET_URL=http://192.168.56.31:7990|BITBUCKET_URL=http://${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}|" ods-core.env
    sed -i "s|REPO_BASE=http://192.168.56.31:7990/scm|REPO_BASE=http://${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}/scm|" ods-core.env

    sed -i "s|CD_USER_ID=.*$|CD_USER_ID=openshift|" ods-core.env
    sed -i "s|CD_USER_ID_B64=.*$|CD_USER_ID_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|CD_USER_PWD_B64=.*$|CD_USER_PWD_B64=$(echo -n openshift | base64)|" ods-core.env

    ## NEXUS
    sed -i "s|NEXUS_USERNAME=.*$|NEXUS_USERNAME=admin|" ods-core.env
    sed -i "s|NEXUS_PASSWORD=.*$|NEXUS_PASSWORD=openshift|" ods-core.env
    sed -i "s|NEXUS_PASSWORD_B64=.*$|NEXUS_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|NEXUS_AUTH=.*$|NEXUS_AUTH=admin:openshift|" ods-core.env
    sed -i "s|NEXUS_URL=.*$|NEXUS_URL=https://nexus-ods.ocp.odsbox.lan|" ods-core.env
    sed -i "s|NEXUS_HOST=.*$|NEXUS_HOST=nexus-ods.ocp.odsbox.lan|" ods-core.env


    # SONAR_ADMIN_USERNAME appears to have to be admin
    # sed -i "s|SONAR_ADMIN_USERNAME=.*$|SONAR_ADMIN_USERNAME=openshift|" ods-core.env
    sed -i "s|SONAR_ADMIN_PASSWORD_B64=.*$|SONAR_ADMIN_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|SONAR_DATABASE_PASSWORD_B64=.*$|SONAR_DATABASE_PASSWORD_B64=$(echo -n sonarqube | base64)|" ods-core.env
    sed -i "s|SONAR_CROWD_PASSWORD_B64=.*$|SONAR_CROWD_PASSWORD_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|SONAR_AUTH_TOKEN_B64=.*$|SONAR_AUTH_TOKEN_B64=$(echo -n openshift | base64)|" ods-core.env
    # Toggle value of this line when Atlassian Crowd becomes available / not-available in EDP in a box.
    sed -i "s|SONAR_AUTH_CROWD=.*$|SONAR_AUTH_CROWD=true|" ods-core.env

    # JENKINS
    sed -i "s|APP_DNS=.*$|APP_DNS=ocp.odsbox.lan:8443|" ods-core.env
    sed -i "s|PIPELINE_TRIGGER_SECRET_B64=.*$|PIPELINE_TRIGGER_SECRET_B64=$(echo -n openshift | base64)|" ods-core.env
    sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=openshift|" ods-core.env
    sed -i "s|SHARED_LIBRARY_REPOSITORY=.*$|SHARED_LIBRARY_REPOSITORY=http://${atlassian_bitbucket_host}:${atlassian_bitbucket_port_internal}/scm/opendevstack/ods-jenkins-shared-library.git|" ods-core.env

    sed -i "s|IDP_DNS=[.0-9a-z]*$|IDP_DNS=|" ods-core.env

    # provisioning app settings
    sed -i "s/PROV_APP_ATLASSIAN_DOMAIN=.*$/PROV_APP_ATLASSIAN_DOMAIN=${odsbox_domain}/" ods-core.env
    sed -i "s/PROV_APP_CROWD_PASSWORD=.*$/PROV_APP_CROWD_PASSWORD=ods/" ods-core.env
    sed -i "s|CROWD_URL=.*$|CROWD_URL=http://${atlassian_crowd_host}:${atlassian_crowd_port_internal}/crowd|" ods-core.env

    # OpenShift
    sed -i "s|OPENSHIFT_CONSOLE_HOST=.*$|OPENSHIFT_CONSOLE_HOST=https://ocp.${odsbox_domain}:8443|" ods-core.env
    sed -i "s|OPENSHIFT_APPS_BASEDOMAIN=.*$|OPENSHIFT_APPS_BASEDOMAIN=.ocp.${odsbox_domain}|" ods-core.env

    sed -i "s|DOCKER_REGISTRY=.*$|OPENSHIFT_APPS_BASEDOMAIN=docker-registry-default.ocp.odsbox.lan:5000|" ods-core.env

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
    tailor apply --namespace "${NAMESPACE}" --non-interactive --verbose
    popd


    echo "make configure-nexus:"
    pushd nexus
    local nexus_url
    nexus_url="https://$(oc -n ods get route nexus -ojsonpath='{.spec.host}')"
    local nexus_port
    nexus_port=$(oc -n ods get route nexus -ojsonpath='{.spec.port.targetPort}')
    nexus_port=${nexus_port%-*} # truncate -tcp from 8081-tcp

    ./configure.sh --namespace ods --nexus="${nexus_url}" --insecure --verbose --admin-password openshift
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
    local sonarqube_url
    sonarqube_url=$(oc -n ${NAMESPACE} get route sonarqube -ojsonpath='{.spec.host}')
    echo "Visit ${sonarqube_url}/setup to see if any update actions need to be taken."
    popd

    echo "configure-sonarqube:"
    pushd sonarqube
    ./configure.sh --sonarqube="https://${sonarqube_url}" --verbose --insecure \
        --pipeline-user openshift \
        --pipeline-user-password openshift \
        --admin-password openshift \
        --write-to-config
    popd

    # retrieve sonar qube tokens from where configure.sh has put them
    pushd ../ods-configuration
    git add -- .
    git commit -m "add sonarqube token to configuration"
    git push
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
    echo "make apply-provisioning-app-build:"
    pushd ods-provisioning-app/ocp-config
    # add flag to suppress confluence adapter
    sed -i "/# Confluence properties/a\ \ \ \ \ \ adapters.confluence.enabled=false" cm.yml

    tailor apply --namespace ${NAMESPACE} is,bc --non-interactive --verbose
    popd

    echo "make start-provisioning-app-build:"
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config ods-provisioning-app --verbose


    echo "make apply-provisioning-app-deploy:"
    pushd ods-provisioning-app/ocp-config
    tailor apply --namespace ${NAMESPACE} --exclude is,bc --non-interactive --verbose
    # roll back change to suppress confluence adapter
    git reset --hard
    popd
}

function setup_docgen() {
    echo "Setting up docgen service"
    echo "make apply-doc-gen-build:"
    pushd ods-document-generation-svc/ocp-config
    tailor apply --namespace ${NAMESPACE} --non-interactive --verbose
    popd

    echo "make start-doc-gen-build:"
    ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config ods-doc-gen-svc --verbose
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

function startup_ods() {
    setup_dnsmasq

    # restart and follow mysql
    restart_atlassian_mysql
    printf "Waiting for mysqld to become available"
    until [[ $(docker inspect --format '{{.State.Health.Status}}' ${atlassian_mysql_container_name}) == 'healthy' ]]
    do
        printf .
        sleep 1
    done
    echo "mysqld up and running."

    restart_atlassian_crowd
    restart_atlassian_bitbucket &
    restart_atlassian_jira &

    startup_openshift_cluster
}

function stop_ods() {
    docker container stop "${atlassian_mysql_container_name}"
    docker container stop "${atlassian_bitbucket_container_name}"
    docker container stop "${atlassian_jira_container_name}"
    docker container stop "${atlassian_crowd_container_name}"
    echo "Stopping ods cluster"
    oc cluster down
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
    setup_dnsmasq
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
    # TODO: push to function
    sudo systemctl restart dnsmasq

    configure_bitbucket2crowd
    # TODO wait until BitBucket (and Jira) becomes available
    create_empty_ods_repositories
    initialise_ods_repositories
    configure_jira2crowd

    create_configuration
    install_ods_project
    # Install components in OpenShift
    setup_nexus &
    setup_sonarqube &
    setup_jenkins &
    setup_provisioning_app &
    setup_docgen &

    local fail_count
    fail_count=0
    for job in $(jobs -p)
    do
        echo "Waiting for openshift build ${job} to complete."
        wait "${job}" || fail_count=$((fail_count + 1))
        echo "build job ${job} returned. Number of failed jobs is ${fail_count}"
        # TODO fail if any job fails
    done

    setup_jenkins_slaves

    echo "Installation completed."
    echo "Now start a new terminal session or run:"
    echo "source /etc/bash_completion.d/oc"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --branch) ods_git_ref="$2"; shift;;
  --target) target="$2"; shift;;

esac; shift; done


# the next line will make bash try to execute the script arguments in the context of this script,
# thus supporting syntax like this:
# bash deployments.sh install_docker
# bash is used here to start a subshell in case there is an exit command in a function to not to
# kill the parent shell from where the script is getting called.
ods_git_ref="${ods_git_ref:-feature/ods-devenv}"
echo "Will build ods box against git-ref ${ods_git_ref}"
${target}
