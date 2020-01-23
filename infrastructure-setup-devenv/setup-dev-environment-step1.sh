#!/usr/bin/env bash

################################################################################
#### README!
#### =======
#### This script is meant to setup a development environment VM that runs ODS
#### in a selfcontained way without access to BI infrastructure.
#### Steps:
#### - Setup an Ubuntu 16.04 LTS vm.
####   The current version of this script will not work on newer Ubuntu versions.
#### - Checkout the ods-core repository from github
#### - run this script to
#### -- install all required dependencies.
####    Then continue with setup-dev-environment-step2.sh to
#### -- install the OpenShift command line tools
#### -- install, configure and start the oc cluster
#### -- install and configure the CD namespace, deploying the ODS application
################################################################################

set -e -o pipefail

################################################################################
#### CONFIGURATION BLOCK
#### Configure script behavior
################################################################################

function install_apt_packages() {
  echo "Installing apt packages. Please enter sudo password if required."
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get install -y curl vim jq
}

function setup_golang() {
  if [[ -n $(command -v go) ]] && grep -q "1.13" <<< "$(go version)" ; then
    echo "go 1.13 installation found on system.";
  else
    echo "Installing goloang v1.13 on system"
    mkdir -p "$HOME/Downloads/golang113" && cd "$HOME/Downloads/golang113"
    curl https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz --output go1.13.3.linux-amd64.tar.gz
    tar xzf go1.13.3.linux-amd64.tar.gz
    if [[ -d /usr/local/go ]]; then echo "Cleaning up old golang installation"; sudo rm -rf /usr/local/go; fi
    sudo mv go /usr/local/
    # shellcheck disable=SC2016
    if ! grep -q "/usr/local/go/bin" "$HOME/.bashrc"; then
      echo "updating PATH"
      echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
      source "$HOME/.bashrc"
    fi
  fi
  # verify installation:
  # verify go 1.13 is available now (after running installation)
  if [[ -z $(command -v go) ]] || ! grep -q "1.13" <<< "$(go version)" ; then
    echo "golang installation has failed! Stopping setup script!"
    exit 1
  fi
  # log go version
  go version
}

function setup_openshift_client() {
  if [[ -n $(command -v oc) ]] && grep -q "v3.11" <<< "$(oc version)"; then
    echo "OpenShift client v3.11 installation found on system."
  else
    echo "Installing OpenShift client v3.11 on system"
    if [[ -d "$HOME/Downloads/OpenShift" ]]; then echo "Cleaning up old OpenShift downloads"; rm -rf "$HOME/Downloads/OpenShift"; fi
    mkdir -p "$HOME/Downloads/OpenShift" && cd "$HOME/Downloads/OpenShift"
    curl -LO https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
    tar xzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
    sudo mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin/oc
  fi
  # verify installation
  if [[ -z $(command -v oc) ]] || ! grep -q "v3.11" <<< "$(oc version)"; then
    echo "OpenShift client installation has failed! Stopping setup script!"
    exit 1
  fi
  # log OpenShift client version
  echo "Installed OpenShift client v3.11"
  oc version
}

function setup_ods_tailor() {
  if [[ -n $(command -v tailor) ]]; then
    echo "ODS tailor installation found on system."
  else
    mkdir -p "$HOME/Downloads/ods_tailor" && cd "$HOME/Downloads/ods_tailor"
    curl -LO "https://github.com/opendevstack/tailor/releases/download/v0.11.0/tailor-linux-amd64"
    chmod +x tailor-linux-amd64
    sudo mv tailor-linux-amd64 /usr/local/bin/tailor
  fi
  # verify installation
  if [[ -z $(command -v tailor) ]]; then
    echo "ODS tailor installation has failed! Stopping the setup script!"
    exit 1
  fi
  # log tailor version
  tailor version
}

function setup_docker() {
  if [[ -n $(command -v docker) ]]; then
    echo "docker installation found on system."
  else
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # verify finger print
    if ! grep -q "0EBFCD88" <<< "$(sudo apt-key fingerprint 0EBFCD88)"; then
      echo "docker repository fingerprint could not be verified. Please check. Stopping the setup script!"
      exit 1
    fi
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker "$USER"
  fi
}

function write_bash_profile() {
  # to make sure .bashrc gets sourced when bash is started as interactive login shell, source it from .bash_profile
  if [[ ! -f "$HOME/.bash_profile" ]] || ! grep -q '^source .bashrc$' "$HOME/.bash_profile"; then echo "source .bashrc" >> "$HOME/.bash_profile"; fi
}

function print_finish_message() {
  echo
  echo "For the changes to take effect, now please log out and log in again (required for docker group update)."
  echo "After login, continue by executing the script setup-dev-environment-step2.sh"
  echo "$(basename "$0") "
}

function main() {
	write_bash_profile
	install_apt_packages
	setup_golang
	setup_openshift_client
	setup_ods_tailor
	setup_docker

  echo
  echo "Installation of required software packages succeeded."
  echo "To make changes take effect it is necessary that you now log out of the system and log back in again"
  echo "After logging back in, please execute script"
  echo "setup-dev-environment-step2.sh"
  echo "to startup the OpenShift cluster, configure the ODS application and install the Atlassian tool suite."
}

main
