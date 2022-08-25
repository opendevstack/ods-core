#!/usr/bin/env bash

set -euo pipefail

echo "${0}"
echo -n "whoami: "
whoami

# install aws cli
curl -sSL --retry 5 --retry-delay 5 --retry-max-time 300 "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

mkdir -p bin logs opendevstack/builds opendevstack/packer_build_result tmp
cd opendevstack || exit 1
git clone https://github.com/opendevstack/ods-core.git

echo " "
echo "DONE."
echo " "
