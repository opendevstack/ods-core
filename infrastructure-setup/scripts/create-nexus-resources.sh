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
echo -e "Deactivate anonymous access\n"
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script" -d @json/deactivateAnonymous.json
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: text/plain' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/deactivateAnonymous/run"
sleep 3s
curl -u admin:admin123 --insecure -k -X DELETE "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/deactivateAnonymous"
sleep .5s
echo -e "Setup developer role\n"
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script" -d @json/createRole.json
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createRole/run" -d @json/developer-role.json
sleep 3s
echo -e "Setup developer user\n"
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script" -d @json/createUser.json
curl -u admin:admin123 --insecure -k -X POST --header 'Content-Type: application/json' "https://nexus-cd.192.168.56.101.nip.io/service/rest/v1/script/createUser/run" -d @json/developer-user.json
sleep .5s
