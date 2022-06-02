#!/usr/bin/env bash

echo " "
echo "Freeing unused resources... "

if docker ps -a | grep -q 'Exited .* ago' ; then
    docker ps -a | grep 'Exited .* ago' | sed 's/\s\+/ /g' | cut -d ' ' -f 1 | while read id; do echo "docker rm $id"; docker rm $id; done
else
    echo "No docker containers to remove. "
fi

oc adm prune images --keep-tag-revisions=1 --keep-younger-than=30m --confirm || true

echo " "
exit 0
