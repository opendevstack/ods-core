# Creating a flask admin BaseView
from airflow.www.utils import SuperUserMixin
from flask import Blueprint
from flask_admin import BaseView, expose

from openshift_plugin.view.openshift_cluster_view import OpenshiftClusterView
from openshift_plugin.view.openshift_worker_image_sync_view import OpenshiftWorkerImageSyncView

class OpenshiftVersionView(BaseView, SuperUserMixin):
    @expose('/')
    def version(self):
        return self.render("openshift_version_view.html", content="Hello galaxy!")


blueprint = Blueprint(
    "openshift_plugin", __name__,
    template_folder='templates',  # registers airflow/plugins/templates as a Jinja template folder
    static_folder='static',
    static_url_path='/static/openshift_plugin')

views = [
    OpenshiftClusterView(category="OpenShift", name="Airflow Cluster"),
    OpenshiftWorkerImageSyncView(category="OpenShift", name="Worker Image DAGs Sync")
]