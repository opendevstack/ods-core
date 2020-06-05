#!/bin/bash
set -eux
set -o pipefail

source ~/.bashrc

if [ !-d ods-core/.git ]; then
    cd ods-core && git init && cd -
fi

cd ods-core/tests

./scripts/recreate-test-infrastructure.sh

make test
