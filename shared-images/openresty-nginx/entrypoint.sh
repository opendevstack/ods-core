#!/usr/bin/env sh

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

# setting up the resolver for nginx
cat > /etc/nginx/resolver.conf << EOF
$(grep nameserver /etc/resolv.conf | head -n 1 | sed -e 's/nameserver/resolver/' -e 's/$/;/')
EOF

# setting up the main modsecurity module initialisation configs for nginx
cat > /etc/nginx/modsecurity-init.conf << EOF
modsecurity ${WAF_MODSECURITY:=off};
modsecurity_rules_file /etc/nginx/modsecurity.conf;
EOF

case "$1" in
  nginx)
    exec "$@"
    ;;
  version)
    exec nginx -V
    ;;
  test)
    exec nginx -T
    ;;
  *)
    # Just run any CMD
    exec "$@"
    ;;
esac
