import os
from pprint import pprint

from airflow import configuration
from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.contrib.kubernetes.kubernetes_request_factory.kubernetes_request_factory import KubernetesRequestFactory
from airflow.contrib.kubernetes.kubernetes_request_factory.pod_request_factory import SimplePodRequestFactory
from openshift_plugin.util import convert_dict_key_case


class OpenshiftRequestFactory(SimplePodRequestFactory):
    """
        This class overwrites
        airflow.contrib.kubernetes.kubernetes_request_factory.pod_request_factory.SimplePodRequestFactory
        to replace the behavior of:
        * extract_cmds to make it compatible with the BIX provided Dockerfile
        * extract_env_and_secrets to replicate the environment of the running scheduler
            pod to make it compatible with the BIX provided Dockerfile
    """

    @staticmethod
    def extract_cmds(pod, req):
        req['spec']['containers'][0]['command'] = ["/entrypoint.sh"] + pod.cmds

    @staticmethod
    def extract_labels(pod, req):
        KubernetesRequestFactory.extract_labels(pod, req)
        req['metadata']['labels']['cluster'] = 'airflow'
        req['metadata']['labels']['component'] = 'airflow-worker'

    @staticmethod
    def extract_env_and_secrets(pod, req):
        KubernetesRequestFactory.extract_env_and_secrets(pod, req)

        env = req['spec']['containers'][0]['env'].copy()
        env = [i for i in env if not i["name"].startswith("AIRFLOW")]
        kube_client = get_kube_client()

        if configuration.conf.getboolean("kubernetes", "in_cluster"):
            pod_config = kube_client.read_namespaced_pod(name=os.getenv("HOSTNAME"),
                                                         namespace=configuration.conf.get("kubernetes", "namespace"))
        else:
            pods = kube_client.list_namespaced_pod(namespace=configuration.conf.get("kubernetes", "namespace"),
                                                   label_selector="component=airflow-scheduler")
            pod_config = pods.items[0]

        self_env = [convert_dict_key_case(e.to_dict())
                    for e in pod_config.spec.containers[0].env
                    if e.name not in ["AIRFLOW_COMMAND", "AIRFLOW_EXECUTOR"]]

        self_env.append({"name": "AIRFLOW_EXECUTOR", "value": "LocalExecutor"})

        if configuration.conf.has_option("core", "worker_logging_level"):
            self_env.append({"name": "AIRFLOW__CORE__LOGGING_LEVEL",
                             "value": configuration.conf.get("core", "worker_logging_level")})
            self_env.append({"name": "AIRFLOW__CORE__FAB_LOGGING_LEVEL",
                             "value": configuration.conf.get("core", "worker_logging_level")})

        req['spec']['containers'][0]['env'] = self_env + env

        self_env_from = [convert_dict_key_case(e.to_dict())
                         for e in pod_config.spec.containers[0].env_from]

        req['spec']['containers'][0]['envFrom'] = self_env_from
