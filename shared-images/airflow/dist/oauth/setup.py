#!/usr/bin/env python

import setuptools

setuptools.setup(name='airflow-oauth',
                 version='0.1',
                 description='Airflow Generic OAuth Authentication',
                 url='https://www.python.org/sigs/distutils-sig/',
                 packages=setuptools.find_packages(),
                 install_requires=[
                     'Flask-OAuthlib>=0.9.1'
                 ]
                 )
