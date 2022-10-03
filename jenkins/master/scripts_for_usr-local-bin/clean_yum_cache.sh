#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"

yum clean all || true
rm -rf /var/cache/yum/* || true
