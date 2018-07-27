#!/bin/bash

set -uo pipefail

case "$TRAVIS_OS_NAME" in
  linux)

    echo "==> Building test cases..."
    docker build  -f test/Dockerfile-$LINUX  -t java_$LINUX   .

    echo "==> Run java..."
    docker run -i java_$LINUX   2> result-$LINUX

    echo "==> Validating the test results..."

    cat result-$LINUX
    sh -c "[ -s result-$LINUX ]"
  ;;
  osx)

    echo "==> Running tests using ansible-playbook on Mac OS X..."
    ansible-playbook test.yml --extra-vars test_hosts=localhost

    echo "==> Validating the test results..."
    java -version  2> result-macosx
    sh -c "[ -s result-macosx      ]"
  ;;
  *)
    echo "Unknown value of TRAVIS_OS_NAME: '$TRAVIS_OS_NAME'" >&2
    exit 1
esac
