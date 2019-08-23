import datetime
import json
from urllib.parse import quote_plus

import requests

from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.contrib.kubernetes.pod import Pod
from airflow.contrib.kubernetes.pod_launcher import PodLauncher
from airflow.models import TaskInstance, Log
from airflow.utils.db import provide_session
from openshift_plugin.executor.openshift_request_factory import OpenshiftRequestFactory


class OpenShiftPodLauncer(PodLauncher):
    """
        This class overwrites airflow.contrib.kubernetes.pod_launcher.PodLauncher to replace the
        default request factory for the OpenshiftRequestFactory
    """

    EVENT_POD_CREATION = "pod_creation"

    def __init__(self, kube_client=None, in_cluster=True, cluster_context=None, extract_xcom=False):
        super(OpenShiftPodLauncer, self).__init__(kube_client, in_cluster, cluster_context, extract_xcom)
        self.kube_req_factory = OpenshiftRequestFactory()

    def run_pod_async(self, pod):
        resp = super(OpenShiftPodLauncer, self).run_pod_async(pod)
        self.log_pod_creation(pod, resp)
        return resp

    @provide_session
    def log_pod_creation(self, pod: Pod, resp, session=None):
        from openshift_plugin.executor.airflow_openshift_scheduler import AirflowOpenShiftScheduler

        execution_date = AirflowOpenShiftScheduler.label_safe_datestring_to_datetime(pod.labels['execution_date'])

        task_instance = session.query(TaskInstance) \
            .filter(TaskInstance.dag_id == pod.labels['dag_id']) \
            .filter(TaskInstance.task_id == pod.labels['task_id']) \
            .filter(TaskInstance.execution_date == execution_date).first()

        if not task_instance:
            self.log.error(
                "Could not find task instance based on the pod labels"
                " ({dag_id} {task_id} {execution_date} {try_number})".format(
                    **pod.labels))
            self.log.error("Log information will be incomplete. This is a BUG please report!!!")

        def default(o):
            if isinstance(o, (datetime.date, datetime.datetime)):
                return o.isoformat()

        kube_client = get_kube_client()

        headers = {"Authorization": kube_client.api_client.configuration.get_api_key_with_prefix('authorization')}
        url = "{0}/apis/image.openshift.io/v1/namespaces/{1}/imagestreamtags/{2}".format(
            kube_client.api_client.configuration.host,
            pod.image.split("/")[-2], quote_plus(pod.image.split("/")[-1]))

        response = requests.get(url,
                                headers=headers,
                                verify=kube_client.api_client.configuration.ssl_ca_cert)

        resp = resp.to_dict()

        if response.status_code == 200:
            image_reference = response.json()
            resp['spec']['containers'][0]['image'] = image_reference["tag"]["from"]["name"]
        else:
            image_reference = None

        log = Log(
            event=OpenShiftPodLauncer.EVENT_POD_CREATION,
            dag_id=task_instance.dag_id,
            task_instance=None,
            task_id=task_instance.task_id,
            execution_date=task_instance.execution_date,
            extra=json.dumps(
                {
                    "request": self.kube_req_factory.create(pod),
                    "response": resp,
                    "image": image_reference
                }, default=default)
        )
        session.add(log)
        session.commit()
        pass
