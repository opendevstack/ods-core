from pprint import pprint
import subprocess
import re
from urllib.parse import quote_plus

import requests
from flask_admin import BaseView, expose

from airflow.contrib.kubernetes.kube_client import get_kube_client
from airflow.executors import GetDefaultExecutor
from airflow.utils.db import provide_session
from airflow.www.utils import SuperUserMixin

from dateutil import parser

from openshift_plugin.models import OpenShiftSyncRequest
from openshift_plugin.view.openshift_cluster_view import OpenshiftClusterView


class OpenshiftWorkerImageSyncView(BaseView, SuperUserMixin):

    @expose('/')
    def get_sync(self):
        return self.render("openshift_worker_image_sync_view.html")

    @expose('/', methods=['POST'])
    def post_sync(self):
        dag_tar, pod = self.get_dag_tag()

        kube_client = get_kube_client()

        headers = {"Authorization": kube_client.api_client.configuration.get_api_key_with_prefix('authorization')}
        url = "{0}/apis/image.openshift.io/v1/namespaces/{1}/imagestreamtags/{2}".format(
            kube_client.api_client.configuration.host,
            pod.image.split("/")[-2], quote_plus(pod.image.split("/")[-1]))

        response = requests.get(url,
                                headers=headers,
                                verify=kube_client.api_client.configuration.ssl_ca_cert)

        if response.status_code == 200:
            image = response.json()
        else:
            image = None

        echo = subprocess.Popen(("echo", dag_tar.decode("utf-8")), stdout=subprocess.PIPE)
        base64 = subprocess.Popen(("base64", "-d"), stdin=echo.stdout, stdout=subprocess.PIPE)
        output = subprocess.check_output(("tar", "-tzv"), stdin=base64.stdout)
        echo.wait()
        return self.render("openshift_worker_image_sync_view.html", files=self.parse_tar_list(output),
                           image=image,
                           image_url="{0}/console/project/dsi-test/browse/images/{1}/{2}?tab=body".format(
                               OpenshiftClusterView.HOST, image['metadata']['name'].split(":")[0],
                               image['tag']['name']))

    def get_dag_tag(self):
        _, dag_tar, pod = GetDefaultExecutor().get_image_dag_info()
        return dag_tar, pod

    @expose('/requestsync', methods=['POST'])
    def request_sync(self):
        self.create_request()

        self.sync_dags()

        return self.render("openshift_worker_image_sync_view.html",
                           request_sync="Data was sync on the webserver. THe scheduler sync is scheduled.")

    def sync_dags(self):
        GetDefaultExecutor().sync_dags()

    @provide_session
    def create_request(self, session=None):
        request = OpenShiftSyncRequest()
        session.add(request)
        session.commit()

    def parse_tar_list(self, bytes):
        string = bytes.decode("utf-8")
        rows = []
        for line in string.split("\n"):
            if not line:
                continue
            row = re.split(r"\s+", line)
            if len(row) != 6 or row[-1] == "./":
                continue
            row = {
                "size": row[2],
                "datetime": parser.parse("{0} {1}".format(row[3], row[4])),
                "filename": row[5][2:]
            }

            rows.append(row)

        return rows
