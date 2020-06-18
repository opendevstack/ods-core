#!/usr/bin/env bash

ods_git_ref=feature/ods-devenv

sudo yum install -y git

opendevstack_dir="${HOME}/opendevstack"
mkdir -p "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/ods-setup/repos.sh
chmod u+x ./repos.sh
./repos.sh --init --confirm --source-git-ref "${ods_git_ref}" --target-git-ref "${ods_git_ref}" --verbose

cd ods-core && git checkout -t origin/"${ods_git_ref}"
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
