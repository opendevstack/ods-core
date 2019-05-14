import json

import elasticsearch
import requests
from elasticsearch_dsl import Search
from flask import jsonify
from flask_admin import BaseView, expose
from kubernetes.client.rest import ApiException
from werkzeug.exceptions import abort

from airflow import LoggingMixin, configuration
from airflow.config_templates.airflow_local_settings import ELASTICSEARCH_HOST
from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.models import TaskInstance, Log
from airflow.utils.db import provide_session
from airflow.www.utils import SuperUserMixin
from openshift_plugin.executor.openshift_pod_launcher import OpenShiftPodLauncer


class OpenshiftClusterView(BaseView, SuperUserMixin, LoggingMixin):
    AIRFLOW_LABEL = "cluster=airflow"
    HOST = configuration.get('openshift_plugin', 'openshift_console_url')

    @expose('/')
    def cluster_view(self):
        kube_client = get_kube_client()
        namespace = configuration.get("kubernetes", "namespace")

        pods = kube_client.list_namespaced_pod(namespace=namespace, label_selector=self.AIRFLOW_LABEL)
        return self.render("openshift_cluster_view.html", namespace=namespace,
                           pods=pods)

    @expose('/api/infrastructure')
    def infrastructure(self):

        kube_client = get_kube_client()
        namespace = configuration.get("kubernetes", "namespace")

        headers = {"Authorization": kube_client.api_client.configuration.get_api_key_with_prefix('authorization')}
        url = "{0}/oapi/v1/namespaces/{1}/deploymentconfigs".format(kube_client.api_client.configuration.host,
                                                                    namespace)

        response = requests.get(url,
                                headers=headers,
                                params={
                                    "labelSelector": self.AIRFLOW_LABEL
                                },
                                verify=kube_client.api_client.configuration.ssl_ca_cert)

        if response.status_code == 200:
            deployment_configs = response.json()
        else:
            return abort(response.status_code)

        try:
            pods = kube_client.list_namespaced_pod(namespace=namespace, label_selector=self.AIRFLOW_LABEL)
            pods = pods.to_dict()
        except ApiException:
            return abort(401)

        return jsonify(self.to_graph(namespace=namespace, oc_deployment_configs=deployment_configs, oc_pods=pods))

    @expose('/api/pod/<pod>')
    def pod(self, pod):
        task_instances = self.get_task_instances(pod=pod)
        if not task_instances:
            abort(404)

        kube_client = get_kube_client()
        namespace = configuration.get("kubernetes", "namespace")
        client = elasticsearch.Elasticsearch([ELASTICSEARCH_HOST])

        count = Search(using=client) \
            .query('match', **{"beat.hostname": pod}) \
            .sort('offset') \
            .count()
        task_instance = task_instances
        try:
            pod = kube_client.read_namespaced_pod(name=pod, namespace=namespace)
            pod = self.pod_info(oc_pod=pod.to_dict(), task_instance=task_instance, namespace=namespace, host=self.HOST)
        except ApiException:
            pod = self.pod_info(oc_pod=self.get_pod_from_log_info(task_instance=task_instance),
                                task_instance=task_instance,
                                namespace=namespace, host=self.HOST)
        pod['log'] = {
            "count": count
        }

        return jsonify(pod)

    @provide_session
    def get_task_instances(self, session=None, pod=None):
        if pod:
            return session.query(TaskInstance).filter(TaskInstance.hostname == pod).order_by(
                TaskInstance.hostname).first()
        else:
            return session.query(TaskInstance).order_by(TaskInstance.hostname).all()

    def pod_info(self, oc_pod, task_instance, host, namespace, add_logs=False):
        pod_name = oc_pod['metadata']['name']

        pod = {
            "name": pod_name,
            "creation_timestamp": oc_pod['metadata']['creation_timestamp'],
            "deployment": oc_pod['metadata']['labels']['deployment'] if "deployment" in
                                                                        oc_pod['metadata'][
                                                                            'labels'] else None,
            "deploymentConfig": oc_pod['metadata']['labels']['deploymentconfig'] if "deploymentconfig" in
                                                                                    oc_pod['metadata'][
                                                                                        'labels'] else None,
            "status": oc_pod['status']['container_statuses'] if 'container_statuses' in oc_pod['status'] and
                                                                oc_pod['status']['container_statuses'] else None,
            "image": {
                "reference": oc_pod['spec']['containers'][0]['image'],
                "url": self.get_image_url(host, namespace, oc_pod['spec']['containers'][0]['image'])
            },
            "url": "{0}/console/project/{1}/browse/pods/{2}?tab=details".format(
                host,
                namespace,
                pod_name),
            'taskInstance': self.task_instance_info(task_instance=task_instance) if task_instance else None
        }

        return pod

    def task_instance_info(self, task_instance):
        return {
            "taskId": task_instance.task_id,
            "dagId": task_instance.dag_id,
            "executionDate": task_instance.execution_date,
            "startDate": task_instance.start_date,
            "endDate": task_instance.end_date,
            "duration": task_instance.duration,
            "state": task_instance.state,
            "tryNumber": task_instance.try_number,
        }

    @provide_session
    def get_pod_from_log_info(self, task_instance, session=None):
        log = session.query(Log) \
            .filter(Log.task_id == task_instance.task_id) \
            .filter(Log.dag_id == task_instance.dag_id) \
            .filter(Log.execution_date == task_instance.execution_date) \
            .filter(Log.event == OpenShiftPodLauncer.EVENT_POD_CREATION).first()

        if not log:
            self.log.error(
                "Could not find log entry for the pod creation of task {0}. This is a BUG, please report!".format(
                    task_instance))

            return {
                "metadata": {
                    "name": task_instance.hostname,
                    "creation_timestamp": None
                },
                "labels": {},
                "spec": {
                    "containers": [{
                        "image": None
                    }]
                },
                "status": {
                    "container_statuses": [{
                        "state": None
                    }]
                }

            }

        extra = json.loads(log.extra)
        if "image" in extra:
            extra['response']['spec']['containers'][0]['image'] = extra["image"]["tag"]["from"]["name"]

        return extra['response']

    def to_graph(self, namespace, oc_deployment_configs, oc_pods):

        connections = [{
            "to": "airflow-postgresql",
            "from": "airflow-scheduler"
        }, {
            "from": "airflow-postgresql",
            "to": "airflow-scheduler"
        }, {
            "to": "airflow-postgresql",
            "from": "airflow-webserver"
        }, {
            "from": "airflow-postgresql",
            "to": "airflow-webserver"
        }, {
            "to": "airflow-postgresql",
            "from": "airflow-workers"
        }, {
            "from": "airflow-postgresql",
            "to": "airflow-workers"
        }, {
            "to": "airflow-postgresql",
            "from": "airflow-terminated-workers"
        }, {
            "from": "airflow-postgresql",
            "to": "airflow-terminated-workers"
        }, {
            "to": "airflow-terminated-workers",
            "from": "airflow-elasticsearch"
        }, {
            "to": "airflow-workers",
            "from": "airflow-elasticsearch"
        }, {
            "to": "airflow-webserver",
            "from": "airflow-elasticsearch"
        }, {
            "from": "airflow-webserver",
            "to": "airflow-elasticsearch"

        }, {
            "to": "airflow-scheduler",
            "from": "airflow-elasticsearch"
        }, {
            "to": "airflow-elasticsearch-kibana",
            "from": "airflow-elasticsearch"
        }, {
            "from": "airflow-elasticsearch-kibana",
            "to": "airflow-elasticsearch"
        }]

        task_instances = self.get_task_instances()

        deployment_configs = {
            "airflow-workers": {
                "name": "airflow-workers",
                "pods": []
            },
            "airflow-terminated-workers": {
                "name": "airflow-terminated-workers",
                "pods": []
            },
        }

        for oc_deployment_config in oc_deployment_configs['items']:
            deployment_config_name = oc_deployment_config['metadata']['name']
            deployment_configs[deployment_config_name] = {
                "name": deployment_config_name,
                "creationTimestamp": oc_deployment_config['metadata']['creationTimestamp'],
                "pods": [],
                "url": "{0}/console/project/{1}/browse/dc/{2}?tab=history".format(self.HOST, namespace,
                                                                                  deployment_config_name)
            }
        for oc_pod in oc_pods['items']:
            pod_name = oc_pod['metadata']['name']
            task_instance = next((t for t in task_instances if t.hostname == pod_name), None)

            if task_instance:
                task_instances.remove(task_instance)

            pod = self.pod_info(oc_pod=oc_pod, task_instance=task_instance, namespace=namespace, host=self.HOST)

            deployment_config = pod['deploymentConfig'] if pod["deploymentConfig"] else "airflow-workers"
            deployment_configs[deployment_config]['pods'].append(pod)

        for task_instance in task_instances:
            deployment_configs["airflow-terminated-workers"]["pods"].append({
                "name": task_instance.hostname,
                "taskInstance": self.task_instance_info(task_instance=task_instance),
            })

        for key, deployment_config in deployment_configs.items():
            dc_connections = [c for c in connections if c["from"] == key]
            pods = []
            for c in dc_connections:
                pods = pods + [item for sublist in
                               [dc['pods'] for key, dc in deployment_configs.items() if key == c['to']]
                               for item in sublist]

            for pod in deployment_config['pods']:
                pod["connections"] = [p['name'] for p in pods]

        return deployment_configs

    def get_image_url(self, host, orig_namespace, image_reference: str):
        if "kibana" in image_reference:
            return "https://www.docker.elastic.co"

        if "postgresql" in image_reference:
            return None

        kube_client = get_kube_client()

        image_reference_split = image_reference.split("/")

        image_hash = image_reference_split[-1]
        if len(image_reference_split) >= 2:
            namespace = image_reference_split[-2]
        else:
            namespace = orig_namespace

        if "@" in image_hash:
            image_stream, image_sha256 = image_hash.split("@")
            headers = {"Authorization": kube_client.api_client.configuration.get_api_key_with_prefix('authorization')}
            url = "{0}/oapi/v1/namespaces/{1}/imagestreams/{2}".format(kube_client.api_client.configuration.host,
                                                                       namespace, image_stream)

            response = requests.get(url,
                                    headers=headers,
                                    params={
                                        "labelSelector": self.AIRFLOW_LABEL
                                    },
                                    verify=kube_client.api_client.configuration.ssl_ca_cert)

            if response.status_code == 200:
                image = response.json()
            else:
                return None

            image_tag_name = None
            for image_tag in image['spec']['tags']:
                if image_tag['from']['name'] == image_hash:
                    image_tag_name = image_tag['name']
                    break
        else:
            image_stream, image_tag_name = image_hash.split(":")

        if image_tag_name:
            return "{0}/console/project/{1}/browse/images/{2}/{3}?tab=body".format(
                host,
                namespace,
                image_stream,
                image_tag_name)
        else:
            return None
