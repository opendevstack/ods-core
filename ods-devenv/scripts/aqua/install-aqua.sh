#!/usr/bin/env bash

oc new-project aqua

read -p "Enter Aqua user name: " USER
echo
read -s -p "Enter Aqua password: " PASSWORD
echo
read -p "Enter Aqua email: " EMAIL

oc create secret docker-registry aqua-registry --docker-server=registry.aquasec.com --docker-username=$USER --docker-password=$PASSWORD --docker-email=$EMAIL -n aqua

oc apply -f aqua-deploy/


