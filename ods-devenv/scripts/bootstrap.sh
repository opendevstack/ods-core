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
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXwKT01BaNoSUXaqzrmaM+mRFyx+ERrmVq7v+1Xgtiru+c07l6vaIK6/GE+E/GH4QESB7phl9dLMlmKOXZZqMixa1MD0V0eaFP4YXCaaTGEPyLaNRNhTXert0IihfAucOIzdFGWn1795IshJ7rj/GdQQ0qrAMVYguz4iC+hR1IznuTkJivIvDCuDo5LG+DksisJlGTLpdTZIeCCJgUUFpevJbtcZKwbUqzd6fo0tQiuk/J0TtO4SlXUvDge7mWGxMCIFPTM+e6AFSI6deviiiyhOHzcP9luJQPBpONBXzGcLXMqm1UsYaOl4OsKcyJSk5PgSKBM0KV4RX2Pm3i0vlz7gbvK65sJKQQlBZBm+W16mT3Ke8ytg9I1Kf9/kplKSvSwxOkmClgWCKzxIT7vsozLnSBuPSyTLZ98RuUFhjDvHMFvmGe0oTGaUB0/QQdhROzYRtw7+/CQOzWuZx32B0CtLpd55iyL8261StbY/92B8QDdIQXg9bzsfx6hXSNLlc= openshift@odsbox.lan" >> ${HOME}/.ssh/authorized_keys
    sleep 5
    cat ${HOME}/.ssh/authorized_keys
else
    echo "Key for openshift@odsbox.lan was previously in file ${HOME}/.ssh/authorized_keys "
fi
chmod -c 700 ${HOME}/.ssh
chmod -c 600 ${HOME}/.ssh/authorized_keys


# install modern git version as required by repos.sh
sudo yum update -y || true
sudo yum install -y yum-utils epel-release https://repo.ius.io/ius-release-el7.rpm || true
sudo yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm || true
sudo yum -y install git gitk iproute lsof xrdp tigervnc-server remmina firewalld git2u-all glances golang jq tree etckeeper unzip || true
sudo yum install adoptopenjdk-8-hotspot adoptopenjdk-11-hotspot adoptopenjdk-8-hotspot-jre adoptopenjdk-11-hotspot-jre || true

opendevstack_dir="${HOME}/opendevstack"
mkdir -pv "${opendevstack_dir}"
cd "${opendevstack_dir}" || return
curl -LO https://raw.githubusercontent.com/opendevstack/ods-core/${ods_git_ref}/scripts/repos.sh
chmod u+x ./repos.sh
./repos.sh --git-ref "${ods_git_ref}" --verbose

cd ods-core
time bash ods-devenv/scripts/deploy.sh --branch "${ods_git_ref}" --target basic_vm_setup
