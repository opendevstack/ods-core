#!/bin/bash
set -eu
set -o pipefail

ME="$(basename ${0})"

function usage {
	echo " "
	echo "This script installs the certificate of a host to the centos 7 os trust store."
	echo "${ME}: usage: ${ME} [--url URL] [--port PORT]"
	echo "${ME}: example: ${ME} --url ocp.odsbox.lan --port 8443"
	echo " "
}

target_url="ocp.odsbox.lan"
target_folder="/etc/pki/ca-trust/source/anchors/"
port="8443"

while [[ "$#" -gt 0 ]]; do
  case $1 in

  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  --url) target_url="$2"; shift;;
  --url=*) target_url="${1#*=}";;

  --port) port="$2"; shift;;
  --port=*) port="${1#*=}";;

  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

echo " "

hostname="$(echo "${target_url}" | sed 's|\.|_|g')"
target_file="/etc/pki/ca-trust/source/anchors/${hostname}.pem"
target_file_tmp="/tmp/${hostname}.pem"

echo "openssl s_client -showcerts -host ${hostname} -port ${port}"
openssl s_client -showcerts -host ${target_url} -port ${port} </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${target_file_tmp}"

echo " "
cat ${target_file_tmp}
echo " "
echo "Moving certificate to target file ${target_file}: "
sudo mv -vf ${target_file_tmp} ${target_file}
echo "Updating ca-trust store... "
sudo update-ca-trust
echo " "
echo "DONE"
echo " "

