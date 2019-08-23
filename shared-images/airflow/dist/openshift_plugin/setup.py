#!/usr/bin/env python

import setuptools

setuptools.setup(name='airflow-openshift-plugin',
                 version='0.1',
                 description='Airflow Openshift Plugin',
                 packages=setuptools.find_packages(),
                 install_requires=[
                     'apache-airflow[kubernetes]>=1.10.2, <2.0.0',
                     'intercepts'
                 ],
                 include_package_data=True,
                 entry_points={
                     'airflow.plugins': [
                         'openshift_plugin = openshift_plugin.plugin:OpenShiftPlugin'
                     ]
                 }
                 )
