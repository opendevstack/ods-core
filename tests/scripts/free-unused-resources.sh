#!/usr/bin/env bash

echo "Freeing unused resources... "

docker ps -a | grep 'Exited .* ago' | sed 's/\s\+/ /g' | cut -d ' ' -f 1 | while read id; do echo "docker rm $id"; docker rm $id; done

oc adm prune images --keep-tag-revisions=1 --keep-younger-than=30m --confirm
