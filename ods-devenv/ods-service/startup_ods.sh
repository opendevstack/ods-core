#!/usr/bin/env bash
echo openshift | sudo -S ls
/home/openshift/opendevstack/ods-core/ods-devenv/scripts/deploy.sh --target startup_ods