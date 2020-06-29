#!/usr/bin/env bash
# shutdown ods gracefully
cd "${HOME}/opendevstack/ods-core" || return
bash ods-devenv/scripts/deploy.sh --target stop_ods
