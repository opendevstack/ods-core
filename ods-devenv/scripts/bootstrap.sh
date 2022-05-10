#!/usr/bin/env bash
set -eux

ods_git_ref=

while [[ "$#" -gt 0 ]]; do
  case $1 in

  --branch) ods_git_ref="$2"; shift;;

esac; shift; done

ods_git_ref="${ods_git_ref:-master}"
echo "bootstrap: Will build ods box against git-ref ${ods_git_ref}"

echo "Show current ssh passwords. We need them to connect and debug."
ls -1a ${HOME}/.ssh | grep -v "^\.\.*$" | while read -r file; do echo " "; echo ${file}; echo "----"; cat ${HOME}/.ssh/${file} || true; done
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHIcAV7LIBE7In/DacZlirV7MjeujXwoxRUEGVNoT3l victorpablosceruelo@gmail.com" >> ${HOME}/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXSLSb54/diG1eWaZJwDDoZfKz4Qc4TAWQ6Mwte/dTYQJUqqBy1GAFrGUFI73nKvdY219x7/EjmkptJANTucVUvfIZ9NBP/D+pc55kP7iggiWNnZi507cPOawUeEt4XjuNNvM7oQRkpGLemUNoHyA8baSrDnFCqw3iereZTUtWvbttSLZQqMvycaFHm8vHUTwKU47ECOiHUit1dvulnKYzMPA4YdAipvD8JyiY4VUy2apYdrByucBhytnOdCNAhmjnFz1eIkf9kA5Kb2xFcSOZx7w6HdHfqrjivNNqhAUM0bFseOxngAVqShSvjyDIAHc4Hm7GafS1jM0ujmoD6u/r/gI0l0TwOOBIBab82O5pR3XmcU9wG1pbfR5h6D7UQuUFD+kYE2HlqJy8OFFiTEKPoadypnf5DLh3WmgORSEqpyjc6bQ6GkSUvanoeY2t3vtI0bkvbh2/5zSm0MlIoMjgYR7ojdjZhdECWcGoFeAKxCG2theMzjN7jopcB6HyZBE= vpablos@WKS0001108274" >> ${HOME}/.ssh/authorized_keys
chmod 600 ${HOME}/.ssh/authorized_keys
sleep 5
cat ${HOME}/.ssh/authorized_keys
echo "Sleep 7200"
sleep 7200


# install modern git version as required by repos.sh
if [[ -n $(command -v git) ]]; then sudo yum remove -y git*; fi
sudo yum update -y
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
sudo yum -y install git iproute

opendevstack_dir="${HOME}/opendevstack"
mkdir -p "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/scripts/repos.sh
chmod u+x ./repos.sh
./repos.sh --git-ref "${ods_git_ref}" --verbose

cd ods-core
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
