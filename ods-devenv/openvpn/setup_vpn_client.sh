#!/usr/bin/env bash
set -euo pipefail

function usage {
    printf "Tries to retrieve credentials and client config from an OpenVPN host.\n"
    printf "The user password of the OpenVPN host will be required"
    printf "usage:\n"
    printf "./setup_vpn_client.sh"
    printf "\t--verbose\t\tEnable verbose mode\n"
    printf "\t--openvpn-host-name\t\trequired - ip or public DNS of VPN host.\n"
    printf "\t--config-path\t\toptional - local path to a folder where credentials and config files will be stored\n"
    printf "\t\t\t\tif not specified, \"\${HOME}/openvpn_config\" will be used\n"
    printf "\t--scp-username\trequired - specify ssh user to scp files from the OpenVPN host"
    printf "\t--scp-password\trequired - specify ssh password to scp files from the OpenVPN host"
}

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
    scp "${scp_username}@${openvpn_host_name}:{/etc/openvpn/easy-rsa/keys/ca.crt,/etc/openvpn/easy-rsa/keys/client1.crt,/etc/openvpn/easy-rsa/keys/client1.key,/usr/share/doc/openvpn-2.4.9/sample/sample-config-files/client.conf,/etc/openvpn/easy-rsa/keys/ta.key}" ./

    local config_file
    config_file=odsbox.ovpn
    cp client.conf "${config_file}"

    sed -i '' "s/cert client.crt/cert client1.crt/" "${config_file}"
    sed -i '' "s/key client.key/key client1.key/" "${config_file}"
    sed -i '' "s/remote my-server-1 1194/remote ${openvpn_host_name} 1194/" "${config_file}"
    popd
}

openvpn_host_name=
config_path=
scp_username=

while [[ "$#" -gt 0 ]];
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
    esac
    shift
done

# shellcheck disable=SC2016
: "${config_path:=${HOME}/openvpn_config}"
if [[ -z "${openvpn_host_name}" ]]
then
    echo "openvpn_host_name is required, please provide e.g. a public ip of the VPN host, e.g."
    echo "./setup_vpn_client.sh --openvpn-host-name ec2-3-250-169-37.eu-west-1.compute.amazonaws.com --scp-username openshift --scp-password ##########"
    exit 1
fi
if [[ -z "${scp_username}" ]]
then
    echo "OpenVPN user name is required to download OpenVPN config / credentials from ${openvpn_host_name}, please provide them, e.g."
    echo "./setup_vpn_client.sh --openvpn-host-name ec2-3-250-169-37.eu-west-1.compute.amazonaws.com --scp-username openshift"
    exit 1
fi

setup_from_host
