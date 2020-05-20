#!/usr/bin/env bash

set -eu

atlassian_crowd_software_version=3.7.0
atlassian_crowd_container_name=crowd
atlassian_crowd_port=38080
# docker network internal crowd port
atlassian_crowd_port_internal=8095

openshift_route=172.17.0.1

echo "Started!"

function setup() {

    #### NOTE this is duplicated in ../crowd/setup_crowd.sh

    echo "Starting Atlassian Crowd ${atlassian_crowd_software_version}"
#    local mysql_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_mysql_container_name})
#    echo "Downloading mysql-connector-java"
#    curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.20/mysql-connector-java-8.0.20.jar

    docker volume create --name crowdVolume
    docker container run -v crowdVolume:/var/atlassian/application-data/crowd --name="crowd" -d -p ${atlassian_crowd_port}:${atlassian_crowd_port_internal} atlassian/crowd:${atlassian_crowd_software_version}

    docker cp crowd-provision-app-backup.xml crowd:/var/atlassian/application-data/crowd/shared/backups/crowd-provision-app-backup.xml
    docker exec -it crowd bash -c 'chmod 444 /var/atlassian/application-data/crowd/shared/backups/crowd-provision-app-backup.xml; ls -lart /var/atlassian/application-data/crowd/shared/backups/'

    # Get session cookie
    curl --location --request GET 'http://localhost:8095/crowd/console/' -c crowd_sessionid_cookie.txt

    # Set time limited license
    curl --location --request POST 'http://localhost:8095/crowd/console/setup/setuplicense!update.action' \
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

    # Set install type action
    curl --location --request POST 'http://localhost:8095/crowd/console/setup/installtype!update.action?installOption=install.xml' -b crowd_sessionid_cookie.txt

    # Set setup database option to embedded
    curl --location --request POST 'http://localhost:8095/crowd/console/setup/setupdatabase!update.action' \
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

    # Restore configuration from the backup file
    curl --location --request POST 'http://localhost:8095/crowd/console/setup/setupimport!update.action' \
-b crowd_sessionid_cookie.txt \
--form 'filePath=/var/atlassian/application-data/crowd/shared/crowd-provision-app-backup.xml'

    # Test setup by login into crowd
curl --location --request POST 'http://localhost:8095/crowd/console/login.action' \
-b crowd_sessionid_cookie.txt \
--header 'Content-Type: text/plain' \
--data-raw '{username: "ods", password: "ods", rememberMe: false}'

    local crowd_ip=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${atlassian_crowd_container_name})

    echo "Atlassian crowd-software is listening on ${crowd_ip}:${atlassian_crowd_port_internal} and ${openshift_route}:${atlassian_crowd_port}"

}

function display_usage() {
  echo
  echo "Usage!"
  echo ""
}
