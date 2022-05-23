#!/usr/bin/env bash
set -eux

ods_git_ref=

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --branch) ods_git_ref="$2"; shift;;

esac; shift; done

ods_git_ref="${ods_git_ref:-master}"
echo "bootstrap: Will build ods box against git-ref ${ods_git_ref}"

echo "Show current ssh passwords. We need them to connect and debug."
ls -1a ${HOME}/.ssh | grep -v "^\.\.*$" | while read -r file; do echo " "; echo ${file}; echo "----"; cat ${HOME}/.ssh/${file} || true; done

# install modern git version as required by repos.sh
sudo yum update -y || true
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm || true
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm || true
sudo yum -y install git gitk iproute lsof xrdp tigervnc-server remmina firewalld git2u-all glances golang jq tree etckeeper unzip || true
sudo yum install adoptopenjdk-8-hotspot adoptopenjdk-11-hotspot adoptopenjdk-8-hotspot-jre adoptopenjdk-11-hotspot-jre || true

opendevstack_dir="${HOME}/opendevstack"
mkdir -pv "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/scripts/repos.sh
chmod u+x ./repos.sh
./repos.sh --git-ref "${ods_git_ref}" --verbose

cd ods-core
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
