#!/usr/bin/env bash
sudo yum install -y git
mkdir projects && cd projects || return
git clone https://github.com/opendevstack/ods-core.git
cd ods-core && git checkout -t origin/feature/ods-devenv
time bash ods-devenv/scripts/deploy.sh --branch feature/ods-devenv --target basic_vm_setup
