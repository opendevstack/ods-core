#!/usr/bin/env bash

minishift profile set opendevstack
minishift --profile opendevstack config set memory 8192
minishift --profile opendevstack config set cpus 2
minishift --profile opendevstack config set disk-size 40GB
minishift --profile opendevstack config set vm-driver virtualbox
minishift --profile opendevstack config set openshift-version v3.11.0
