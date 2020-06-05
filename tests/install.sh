#!/bin/bash
set -eux
set -o pipefail

GO_VERSION="1.14.3"
TAILOR_VERSION="1.0.0"
OC_VERSION="3.11.0"
OC_EXACT_VERSION="${OC_VERSION}-0cbc58b"

sudo apt-get update -y

# Make
sudo apt-get install -y build-essential

# ods-core
if [ ! -d ods-core ]; then
    git clone https://github.com/opendevstack/ods-core.git
fi

# Go
cd /tmp
curl -LO https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm -f *.tar.gz
cd -
sudo mkdir -p /go
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "export GOBIN=/usr/local/bin" >> ~/.bashrc
source ~/.bashrc
/usr/local/go/bin/go version

# JQ
sudo apt-get install -y jq
jq --version

# Docker
curl -fsSL https://get.docker.com | sudo sh
docker --version
sudo usermod -aG docker ubuntu
./ods-core/tests/scripts/apply-docker-settings.sh

# OC
wget https://github.com/openshift/origin/releases/download/v${OC_VERSION}/openshift-origin-client-tools-v${OC_EXACT_VERSION}-linux-64bit.tar.gz
tar -xzvf openshift-origin-client-tools-v${OC_EXACT_VERSION}-linux-64bit.tar.gz
sudo mv openshift-origin-client-tools-v${OC_EXACT_VERSION}-linux-64bit/oc /usr/local/bin/oc
oc version

# Tailor
curl -LO "https://github.com/opendevstack/tailor/releases/download/v${TAILOR_VERSION}/tailor-linux-amd64"
chmod +x tailor-linux-amd64
sudo mv tailor-linux-amd64 /usr/local/bin/tailor
tailor version
