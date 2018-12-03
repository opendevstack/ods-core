#!/bin/bash

cd ods-configuration-sample

if [[ `git status --porcelain` ]]; then
  echo "updating configuration ..."
  git pull origin master
else 
  echo "configuration is up to date"
fi

echo "Initializing ods-configuration? (Warning! The script will copie all files from /ods-configuration-sample into /ods-configuration and override all .env files in /ods-configuration)"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) shopt -s extglob
              cp -r ../ods-configuration-sample/. ../ods-configuration;
              find ../ods-configuration -name '*.sample' -type f | while read NAME ; do cp "${NAME}" "${NAME%.sample}"; done; 
              break;;
        No )  break;;
    esac
done
# cp $(find ! ../ods-configuration-sample -name ".git*") ../ods-confiduration; 

echo "Copy sample config to configuration directory?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) cp -r ../ods-configuration-sample/. ../ods-configuration;
              break;;
        No )  exit;;
    esac
done

  
 
 