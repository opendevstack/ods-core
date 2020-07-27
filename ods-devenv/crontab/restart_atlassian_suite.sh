#!/usr/bin/env bash

echo openshift | sudo -S sed -i '0,/%wheel[[:space:]]*ALL=(ALL)[[:space:]]*ALL/{s||%wheel        ALL=(ALL)       NOPASSWD: ALL|}' /etc/sudoers
/home/openshift/opendevstack/ods-core/ods-devenv/scripts/deploy.sh --target restart_atlassian_suite
sudo sed -i '0,/%wheel[[:space:]]*ALL=(ALL)[[:space:]]*NOPASSWD:[[:space:]]*ALL/{s||%wheel  ALL=(ALL)       ALL|}' /etc/sudoers
