#!/bin/bash
set -eux
set -o pipefail

oc cluster up \
    --base-dir=${HOME}/openshift.local.clusterup \
    --routing-suffix 172.17.0.1.nip.io \
    --public-hostname 172.17.0.1 \
    --enable=centos-imagestreams \
    --enable=persistent-volumes \
    --enable=registry \
    --enable=router

oc login -u system:admin
