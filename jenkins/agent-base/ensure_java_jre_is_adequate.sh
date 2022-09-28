#!/bin/bash
set -eu -o pipefail

yum list installed | grep "\(java\|jre\|jdk\)"

if ! yum list installed | grep -q "java-11" ; then
    echo "Java-11 is *not* installed. Installing..."
    yum -y install java-11-openjdk-headless
else
    echo "Java-11 is already installed."
fi

if yum list installed | grep -q "java-1.8" ; then
    echo "Java-8 is installed. Removing..."
    yum -y remove java-1.8*
else
    echo "Java-8 is not installed. Correct."
fi
