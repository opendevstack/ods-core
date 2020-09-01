#!/usr/bin/env bash
set -euo pipefail

function usage {
    printf "Tries to retrieve credentials and client config from an OpenVPN host.\n"
    printf "usage:\n"
    printf "./setup_vpn_client.sh"
    printf "\t--verbose\t\tEnable verbose mode\n"
    printf "\t--openvpn-host-name\t\trequired - ip or public DNS of VPN host.\n"
    printf "\t--config-path\t\toptional - local path to a folder where credentials and config files will be stored\n"
    printf "\t\t\t\tif not specified, \"\${HOME}/openvpn_config\" will be used\n"
    printf "\t--scp-username\trequired - specify ssh user to scp files from the OpenVPN host"
    printf "\t--scp-password\trequired - specify ssh password to scp files from the OpenVPN host"
}

while [[ "#$" -gt 0 ]];
do
    case $1 in
        -v|--verbose)
            set -x
            ;;
        --openvpn-host-name)
            openvpn_host_name="$2"
            shift
            ;;
        --config-path)
            config_path="$2"
            shift
            ;;
        --scp-username)
            scp_username="$2"
            shift
            ;;
        --scp-password)
            scp_password="$2"
            shift
            ;;
    esac
    shift
done

#######################################
# Run this function locally on the intended VPN client to download
# credentials and VPN client config.
# Globals:
#   openvpn_host_name
#   config_path
# Arguments:
#   n/a
# Returns:
#   None
#######################################
function setup_from_host() {
    echo "Creating folder ${config_path} for openvpn client config"
    mkdir -p "${config_path}"
    pushd "${config_path}"
    echo "Downloading credentials and configs from OpenVPN host"
    echo "${scp_password}" | "${scp_username}@${openvpn_host_name}:{/etc/openvpn/ta.key,/etc/openvpn/easy-rsa/keys/ca.crt,/etc/openvpn/easy-rsa/keys/client1.crt,/etc/openvpn/easy-rsa/keys/client1.key,/usr/share/doc/openvpn-2.4.9/sample/sample-config-files/client.conf}" ./
    cp client.conf odsbox.ovpn
    popd
}

:"${config_path:=${HOME}/openvpn_config}"
if [[ -n "${openvpn_host_name}" ]]
then
    echo "openvpn_host_name is required, please provide e.g. a public ip of the VPN host"
    exit 1
fi
if [[ -n "${scp_username}" || -n "${scp_password}" ]]
then
    echo "Credentials are required to download OpenVPN config / credentials from ${openvpn_host_name}"
    exit 1
fi

setup_from_host
