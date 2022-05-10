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

needsKey=0
grep -q "openshift@odsbox.lan" ~/.ssh/authorized_keys || needsKey=1
if [ 1 -eq $needsKey ]; then
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw7exPbJcynoOi2R5TuLCJa9g2yLKUG4fnCzo2Yxxm+xgyTmQoVMww1pYCS9ri1I2l/SOsuu1mXeoXv89H1KXxxxdocqSUgpf5fHSNeN88GaR0P2dQKyf68bDb3DPclRCi09LgHrbYG6bIx8L4pSzZIOzi4K7CPidcb4aSou0nZfHDI/m6uwvv3kkJ6E2aaMIngm4KAFo89iTIoT/YqhfC+2PwSOARhvklBouli8BkQosjUgQrA4TDZM/L3zvaP350EfLV8eJbK4hmEA+nfwe3LGISx81OsA++JBG4t3pNqQfOCjadmrtfjCt8XTjxh86sakkO4BKki7p+d68hURBYNutGzcllGMiTQVan88oMrYdVAgIQUEC2p5BuXGQ1lu4R+tt0iNW0rz37RRF4nB/S39BvuLQ0kkvAhx8Hx9TdQmmo1nCmUvzbN9jHgKSNISm8Bs3NcqCYE3AsAEi3zSPhsVBGFH123q9s8VqMMlPcdcQXLm2gIX1ROiLhOb3uQmk= openshift@odsbox.lan" >> ${HOME}/.ssh/authorized_keys
    sleep 5
    cat ${HOME}/.ssh/authorized_keys
else
    echo "Key for openshift@odsbox.lan was previously in file ${HOME}/.ssh/authorized_keys "
fi
chmod -c 700 ${HOME}/.ssh
chmod -c 600 ${HOME}/.ssh/authorized_keys


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
