#!/usr/bin/env bash
echo -e "Install Blob Stores\n"
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script" -d @json/createBlobStores.json
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: text/plain' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createBlobStores/run"
sleep 3s
curl -u admin:admin123 --insecure -k -X DELETE "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createBlobStores"
sleep .5s
echo -e "Install Repositories\n"
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script" -d @json/createRepos.json
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: text/plain' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createRepos/run"
sleep 3s
curl -u admin:admin123 --insecure -k -X DELETE "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createRepos"
sleep .5s
