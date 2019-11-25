import io
import subprocess
import traceback

from sqlalchemy.orm import Session

from airflow import configuration
from airflow.contrib.executors.kubernetes_executor import KubernetesExecutor, AirflowKubernetesScheduler
from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.contrib.kubernetes.pod import Pod
from airflow.contrib.kubernetes.pod_launcher import PodLauncher
from airflow.settings import AIRFLOW_HOME
from airflow.utils.db import provide_session
from openshift_plugin.executor.airflow_openshift_scheduler import AirflowOpenShiftScheduler
from openshift_plugin.models import OpenShiftSyncRequest


class OpenShiftExecutor(KubernetesExecutor):
    """
        This class overwrites airflow.contrib.executors.kubernetes_executor.KubernetesExecutor to replace the
        default scheduler for the AirflowOpenShiftScheduler
    """

    def terminate(self):
        pass

    def start(self):
        super(OpenShiftExecutor, self).start()
        self.kube_scheduler = AirflowOpenShiftScheduler(
            kube_config=self.kube_config,
            task_queue=self.task_queue,
            result_queue=self.result_queue,
            kube_client=self.kube_client,
            worker_uuid=self.worker_uuid
        )

    def get_image_dag_info(self):
        client = self.kube_client or get_kube_client()
        launcher = PodLauncher(kube_client=client)
        pod = self.create_sync_pod()
        status, result = launcher.run_pod(pod, get_logs=False)

        logs = client.read_namespaced_pod_log(
            name=pod.name,
            namespace=pod.namespace,
            container='base',
            follow=True,
            _preload_content=False)

        launcher.delete_pod(pod)

        return status, logs.data, pod

    def sync_dags(self):
        _, dag_tar, pod = self.get_image_dag_info()
        subprocess.check_call(("rm", "-rf", '{0}/dags/*'.format(AIRFLOW_HOME)))
        echo = subprocess.Popen(("echo", dag_tar.decode("utf-8")), stdout=subprocess.PIPE)
        base64 = subprocess.Popen(("base64", "-d"), stdin=echo.stdout, stdout=subprocess.PIPE)
        subprocess.check_call(
            ("tar", "-C", "{0}/dags".format(AIRFLOW_HOME), "--no-overwrite-dir", "--no-same-owner",
             "--no-same-permissions", "-xzf", "-"),
            stdin=base64.stdout)
        echo.wait()

    def create_sync_pod(self):
        return Pod(
            namespace=configuration.conf.get("kubernetes", "namespace"),
            name=AirflowKubernetesScheduler._create_pod_id("airflow-sync", "sync-worker"),
            image=self.kube_config.kube_image,
            image_pull_policy=self.kube_config.kube_image_pull_policy,
            cmds=[
                "sh",
                "-c",
                "tar -cz --exclude=__pycache__ -C $AIRFLOW_HOME/dags . | base64"
            ],
            labels={
                'cluster': "airflow",
            },
            service_account_name=self.kube_config.worker_service_account_name,
            image_pull_secrets=self.kube_config.image_pull_secrets,
            envs={}
        )

    def sync(self):
        super(OpenShiftExecutor, self).sync()
        self.check_and_sync_dags()

    @provide_session
    def check_and_sync_dags(self, session: Session = None):
        requests = session.query(OpenShiftSyncRequest) \
            .filter(OpenShiftSyncRequest.component == OpenShiftSyncRequest.COMPONENT_SCHEDULER) \
            .filter(OpenShiftSyncRequest.status == OpenShiftSyncRequest.STATUS_REQUESTED) \
            .all()

        if requests:
            # noinspection PyBroadException
            try:
                self.sync_dags()
                status = OpenShiftSyncRequest.STATUS_COMPLETED
                status_message = None
            except Exception as e:
                f = io.StringIO()
                traceback.print_exc(file=f)
                f.seek(0)

                status = OpenShiftSyncRequest.STATUS_FAILED
                status_message = f.read()

            for request in requests:
                request.status = status
                request.status_message = status_message
                session.merge(request)

            session.commit()
