from pprint import pprint

import requests

from airflow import LoggingMixin
from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.utils import configuration


def authorize(oauth_app, authorized_response, user_info):
    with open('/run/secrets/kubernetes.io/serviceaccount/namespace', 'r') as file:
        namespace = file.read()
    kube_client = get_kube_client()

    url = "{0}/apis/rbac.authorization.k8s.io/v1beta1/namespaces/{1}/rolebindings".format(
        kube_client.api_client.configuration.host, namespace)

    response = requests.get(url, headers={
        "Authorization": "Bearer {0}".format(oauth_app.consumer_secret)
    }, verify=kube_client.api_client.configuration.ssl_ca_cert if kube_client.api_client.configuration.ssl_ca_cert else False)
    if response.status_code != 200:
        LoggingMixin().log.error("The service account providing OAuth is not allowed to list rolebindings. Deniyng "
                                 "access to everyone!!!")
        return False, False

    role_binding_list = response.json()
    allowed_roles = []
    for role in role_binding_list['items']:
        def predicate(subject):
            if subject['kind'] in ['ServiceAccount', 'User']:
                return subject['name'] == user_info['metadata']['name']
            elif subject['kind'] is 'Group':
                return subject['name'] in user_info['groups']

        name = role['roleRef']['name']
        if next((x for x in role['subjects'] if predicate(x)), None):
            allowed_roles.append(name)

    allowed_roles = set(allowed_roles)
    access_roles = set(configuration.conf.get('openshift_plugin','access_roles').split(','))
    superuser_roles = set(configuration.conf.get('openshift_plugin', 'superuser_roles').split(','))

    return bool(allowed_roles & access_roles), \
           bool(allowed_roles & superuser_roles)
