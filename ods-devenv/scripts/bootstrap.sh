#!/usr/bin/env bash
set -eux

ods_git_ref=

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --branch) ods_git_ref="$2"; shift;;

esac; shift; done

ods_git_ref="${ods_git_ref:-master}"
echo "bootstrap: Will build ods box against git-ref ${ods_git_ref}"

# install modern git version as required by repos.sh
if [[ -n $(command -v git) ]]; then sudo yum remove -y git*; fi
sudo yum update -y
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
sudo yum -y install git

opendevstack_dir="${HOME}/opendevstack"
mkdir -p "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/ods-setup/repos.sh
chmod u+x ./repos.sh
./repos.sh --init --confirm --bitbucket-ods-project OPENDEVSTACK --source-git-ref "${ods_git_ref}" --target-git-ref "${ods_git_ref}" --verbose

cd ods-core
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
