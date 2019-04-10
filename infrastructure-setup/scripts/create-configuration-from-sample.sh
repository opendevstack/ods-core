#!/bin/bash
#
# We assume that all ods repositories are placed next to each other
# By default it is one level up from this script

ODS_DIR="../../.."
ODS_SAMPLE_DIR=`realpath ${ODS_DIR}/ods-configuration-sample`
ODS_CONFIG_DIR=`realpath ${ODS_DIR}/ods-configuration`

echo ${ODS_SAMPLE_DIR}
echo ${ODS_CONFIG_DIR}

# check if we have a ods-configuration
# and create one
if [[ ! -d "${ODS_CONFIG_DIR}" ]] ; then
  echo "creating ods configuration directory"
  mkdir ${ODS_CONFIG_DIR}
fi

if [ "$(ls -A ${ODS_CONFIG_DIR})" ]; then
  echo "ODS-configuration already initialised"
else 
  echo "Initialising ods-configuration directory."	
  cd ${ODS_SAMPLE_DIR}
  git archive master | tar -x -C ${ODS_CONFIG_DIR}  
  cd ${ODS_CONFIG_DIR}
  rm -f ./.gitignore
  find . -name "*.sample" -exec bash -c 'cp {} $(dirname {})/$(basename {} .sample)' \;

  exit
fi  


# ok, we have an ods configuration
# so lets ensure sample is up to date
cd ${ODS_SAMPLE_DIR}
if [[ `git status --porcelain` ]]; then
  echo "updating configuration ..."
  git pull origin master
  cd ${ODS_SAMPLE_DIR}
  git archive master | tar -x -C ${ODS_CONFIG_DIR}
else 
  echo "configuration is up to date"
fi

