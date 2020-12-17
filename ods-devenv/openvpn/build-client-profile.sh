#!/bin/bash
#
server=${1?"The server address is required"}
protocol=udp
port=1194
cacert=/etc/openvpn/easy-rsa/keys/ca.crt
client_cert=/etc/openvpn/easy-rsa/keys/${2?"The path to the client certificate file is required"}.crt
client_key=/etc/openvpn/easy-rsa/keys/${2}.key
tls_key=/etc/openvpn/easy-rsa/keys/ta.key

if [ "$#" -lt 2 ]; then
    echo "params: <server address> <client>"
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
cat ${client_cert} | sed -n '/.*BEGIN.*/, /.*END.*/p'
cat << EOF
</cert>
<key>
EOF
cat ${client_key}
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
cat ${tls_key} | sed -n '/.*BEGIN.*/, /.*END.*/p'
cat << EOF
</tls-auth>
EOF