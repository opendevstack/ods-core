from airflow.contrib.executors.kubernetes_executor import AirflowKubernetesScheduler
from openshift_plugin.executor.openshift_pod_launcher import OpenShiftPodLauncer


class AirflowOpenShiftScheduler(AirflowKubernetesScheduler):
    """
        This class overwrites airflow.contrib.executors.kubernetes_executor.AirflowKubernetesScheduler to replace the
        default pod launcher for the OpenShiftPodLauncer
    """

    def __init__(self, kube_config, task_queue, result_queue, kube_client, worker_uuid):
        super(AirflowOpenShiftScheduler, self).__init__(
            kube_config=kube_config,
            task_queue=task_queue,
            result_queue=result_queue,
            kube_client=kube_client,
            worker_uuid=worker_uuid
        )
        self.launcher = OpenShiftPodLauncer(kube_client=self.kube_client)

    @classmethod
    def label_safe_datestring_to_datetime(cls, date_str):
        return cls._label_safe_datestring_to_datetime(date_str)
