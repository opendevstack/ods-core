#!/bin/bash
#
# We assume that all ods repositories are placed next to each other
# By default it is one level up from this script

ODS_DIR="../../.."
ODS_SAMPLE_DIR=`realpath ${ODS_DIR}/ods-core/configuration-sample`
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
fi


echo "Initialising ods-configuration directory."
cd ${ODS_SAMPLE_DIR}
./update




