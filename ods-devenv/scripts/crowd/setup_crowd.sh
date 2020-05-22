#!/usr/bin/env bash

set -eu

atlassian_crowd_software_version=3.7.0
atlassian_crowd_container_name=crowd
atlassian_crowd_port=38080
# docker network internal crowd port
atlassian_crowd_port_internal=8095

openshift_route=172.17.0.1

echo "...executing setup_crowd.sh"
echo

function display_usage() {
  echo
  echo "Usage"
  echo "setup: install Crowd in a docker container"
  echo "cleanup: remove 'crowd' docker container and the volume 'odsCrowdVolume'"
  echo
}

function setup() {

    echo "Starting Atlassian Crowd ${atlassian_crowd_software_version} installation"
    docker volume create --name odsCrowdVolume
    docker container run -v odsCrowdVolume:/var/atlassian/application-data/crowd --name="crowd" -d -p ${atlassian_crowd_port}:${atlassian_crowd_port_internal} atlassian/crowd:${atlassian_crowd_software_version}

    sleep 3

    echo
    echo "...copy config 'crowd-provision-app-backup.xml' to container"
    docker container exec crowd bash -c "mkdir -p /var/atlassian/application-data/crowd/shared/; chown crowd:crowd /var/atlassian/application-data/crowd/shared/"
    docker cp crowd-provision-app-backup.xml crowd:/var/atlassian/application-data/crowd/shared/

    echo
    echo "...change permission of config in container"
    docker exec -it crowd bash -c 'chown crowd:crowd /var/atlassian/application-data/crowd/shared/crowd-provision-app-backup.xml; ls -lart /var/atlassian/application-data/crowd/shared/'

    sleep 1

    echo
    echo "...ping crowd web server"
    curl --location --request -GET "http://localhost:$atlassian_crowd_port/" -v

    # Get session cookie
    echo
    echo "...get session cookie from crowd web console"
    curl --location --request GET "http://localhost:$atlassian_crowd_port/crowd/console/" -c crowd_sessionid_cookie.txt

    sleep 1

    # Set time limited license
    echo
    echo "...setup license"
    curl --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setuplicense!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'key=AAACLg0ODAoPeNqNVEtv4jAQvudXRNpbpUSEx6FIOQBxW3ZZiCB0V1WllXEG8DbYke3A8u/XdUgVQ
yg9ZvLN+HuM/e1BUHdGlNvuuEHQ73X73Y4bR4nbbgU9ZwFiD2IchcPH+8T7vXzuej9eXp68YSv45
UwoASYhOeYwxTsIE7RIxtNHhwh+SP3a33D0XnntuxHsIeM5CIdwtvYxUXQPoRIF6KaC0FUGVlEB3
v0hOAOWYiH9abFbgZith3i34nwOO65gsAGmZBhUbNC/nIpjhBWEcefJWelzqIDPWz/OtjmXRYv2X
yqwnwueFkT57x8e4cLmbCD1QnX0UoKQoRc4EUgiaK4oZ2ECUrlZeay75sLNs2JDmZtWR8oPCfWZG
wHAtjzXgIo0SqmZiKYJmsfz8QI5aI+zApuq6fqJKVPAMCPnNpk4LPW6kBWgkZb+kQAzzzS2g6Dnt
e69Tqvsr4SOskIqEFOeggz1v4zrHbr0yLJR8rU64FpQpVtBy1mZxM4CnHC9Faf8tKMnTF1AiXORF
ixyQaWto3RZ+ncWLXtMg6EnKZZRpmQNb2R8tnJXFulCfXmXLry7TrHBWn2HNVyH8WYxj9AzmsxiN
L/R88Xg6rA1lVs4QpO5titxhplJcCY2mFFZLutAZVhKipm15/VhJx36YVqyN8YP7IaGC1+lwnJ7Q
5pJpNmxk5hP3qovutY8Pi4E2WIJ59esnr1p+T6eD67teBVCHf+ga+ho4/4D9YItZDAsAhQ5qQ6pA
SJ+SA7YG9zthbLxRoBBEwIURQr5Zy1B8PonepyLz3UhL7kMVEs=X02q6'

    sleep 1

    # Set install type action
    echo
    echo "...start crowd configuration"
    curl --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/installtype!update.action?installOption=install.xml" -b crowd_sessionid_cookie.txt

    sleep 1

    # Set setup database option to embedded
    echo
    echo "...choose embedded db option"
    curl --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setupdatabase!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'databaseOption= db.embedded' \
--form 'jdbcDatabaseType= ' \
--form 'jdbcDriverClassName= ' \
--form 'jdbcUrl= ' \
--form 'jdbcUsername= ' \
--form 'jdbcPassword= ' \
--form 'jdbcHibernateDialect= ' \
--form 'datasourceDatabaseType= ' \
--form 'datasourceJndiName='

    sleep 1

    # Restore configuration from the backup file
    echo
    echo "...choose install with config file (config file was copied to container already)"
    curl --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/setup/setupimport!update.action" \
-b crowd_sessionid_cookie.txt \
--form 'filePath=/var/atlassian/application-data/crowd/shared/crowd-provision-app-backup.xml'

    sleep 1

    # Test setup by login into crowd
    echo
    echo "...login in crowd to test installation"
curl --location --request POST "http://localhost:$atlassian_crowd_port/crowd/console/login.action" \
-b crowd_sessionid_cookie.txt \
--header 'Content-Type: text/plain' \
--data-raw '{username: "openshift", password: "openshift", rememberMe: false}'

    sleep 1

    local crowd_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_crowd_container_name})

    echo
    echo "Atlassian Crowd installation is done and server listening on ${crowd_ip}:${atlassian_crowd_port_internal} and ${openshift_route}:${atlassian_crowd_port}"
    echo

}

function cleanup() {
    docker stop crowd
    docker container rm crowd
    docker volume rm odsCrowdVolume
    docker container ls -a
}

# the next line will make bash try to execute the script arguments in the context of this script,
# thus supporting syntax like this:
# bash deployments.sh install_docker
# bash is used here to start a subshell in case there is an exit command in a function to not to
# kill the parent shell from where the script is getting called.
"$@"
