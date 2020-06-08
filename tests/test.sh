#!/bin/bash
set -eux
set -o pipefail

cd ods-core/tests

./scripts/recreate-test-infrastructure.sh

make test
