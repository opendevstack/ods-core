#!/bin/bash

#######################################
# Run this script in your EDP / ODS box
# to generate the OpenVPN client profile for the EDP in a box.
# This profile can be used from an openvpn-connect client
# (see https://openvpn.net/downloads/openvpn-connect-v3-windows.msi)
# Arguments:
#   - The server address
#   - The client certificate name (/etc/openvpn/easy-rsa/keys/${2?}.crt)
# Returns:
#   Output the profile to be used by the ovpn client
# Example
#   bash build-client-profile.sh {EC2_INSTANCE} client1 > /home/openshift/clientProfile.ovpn
#######################################

server=${1?"The server address is required"}
protocol=udp
port=1194
cacert=/etc/openvpn/easy-rsa/keys/ca.crt
client_cert=/etc/openvpn/easy-rsa/keys/${2?"The client certificate name is required"}.crt
client_key=/etc/openvpn/easy-rsa/keys/${2}.key
tls_key=/etc/openvpn/easy-rsa/keys/ta.key

if [ "$#" -lt 2 ]; then
    echo "params: <server address> <client-cert-name>"
    exit 1
fi

cat << EOF
setenv FORWARD_COMPATIBLE 1
client
dev tun
remote ${server} ${port}
resolv-retry infinite
nobind
persist-key
persist-tun
verb 3
keepalive 10 600
proto ${protocol}
cipher BF-CBC
<ca>
EOF
cat ${cacert}
cat << EOF
</ca>
<cert>
EOF
sed -n '/.*BEGIN.*/, /.*END.*/p' "${client_cert}"
cat << EOF
</cert>
<key>
EOF
cat "${client_key}"
cat << EOF
</key>
EOF
if [[ -z $tls_key ]]; then
    exit 0
fi
cat << EOF
remote-cert-tls server
key-direction 1
<tls-auth>
EOF
sed -n '/.*BEGIN.*/, /.*END.*/p' "${tls_key}"
cat << EOF
</tls-auth>
EOF
