#!/bin/bash
set -eux
set -o pipefail

source ~/.bashrc

cd ods-core/tests

./scripts/recreate-test-infrastructure.sh

make test
