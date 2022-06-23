#!/usr/bin/env bash
set -eux

ods_git_ref=

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --branch) ods_git_ref="$2"; shift;;

esac; shift; done

ods_git_ref="${ods_git_ref:-master}"
echo "bootstrap: Will build ods box against git-ref ${ods_git_ref}"

echo " "
echo "--------------------------------------------------------------"
echo "Show current ssh passwords. We need them to connect and debug."
echo "--------------------------------------------------------------"
ls -1a ${HOME}/.ssh | grep -v "^\.\.*$" | \
    while read -r file; do echo " "; echo ${file}; echo "------------"; cat ${HOME}/.ssh/${file} || true; done
echo " "
echo "--------------------------------------------------------------"
echo " "

# install modern git version as required by repos.sh
sudo yum update -y || true
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm || true
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm || true
sudo yum -y install git gitk iproute lsof tigervnc-server remmina firewalld git2u-all glances golang jq tree \
            etckeeper unzip \
            adoptopenjdk-8-hotspot adoptopenjdk-11-hotspot adoptopenjdk-8-hotspot-jre adoptopenjdk-11-hotspot-jre \
            || true

echo "Ensure problematic packages are not installed or uninstall them..."
sudo yum -y remove java-1.7.0-openjdk java-1.7.0-openjdk-headless \
                   java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-headless.x86_64 \
                   java-11-openjdk.x86_64 java-11-openjdk-headless.x86_64 || true
echo "Checking installed packages for java (jre, jdk):"
yum list installed | grep -i "\(jre\|java\|jdk\)" || true
echo "Checking the by default configured java: "
ls -la /bin/java /usr/bin/java /etc/alternatives/java || true

echo "Setting/Evaluating JAVA_HOME configuration..."
if grep -q 'JAVA_HOME' /etc/bashrc ; then
    echo "Configuring JAVA_HOME...";
    echo " " >> /etc/bashrc
    echo "export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-11-hotspot/" >> /etc/bashrc
else
    echo "No need to configure JAVA_HOME. Current configuration:";
    grep -i 'JAVA_HOME' /etc/bashrc || true
fi
echo " "

opendevstack_dir="${HOME}/opendevstack"
mkdir -pv "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/scripts/repos.sh
chmod u+x ./repos.sh
./repos.sh --git-ref "${ods_git_ref}" --verbose

cd ods-core
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
