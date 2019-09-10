from airflow.plugins_manager import AirflowPlugin
from openshift_plugin.executor.openshift_executor import OpenShiftExecutor
from openshift_plugin.models import OpenShiftSyncRequest
from openshift_plugin.views import blueprint, views


class OpenShiftPlugin(AirflowPlugin):
    name = "openshift_plugin"
    operators = []
    sensors = []
    hooks = []
    executors = [OpenShiftExecutor]
    macros = []
    admin_views = views
    flask_blueprints = [blueprint]
    menu_links = []
    appbuilder_views = []
    appbuilder_menu_items = []


OpenShiftSyncRequest.create_table()


def patch_airflow():
    from elasticsearch_dsl import Search

    # Patch for making Airflow talk to Elastic Search / FileBeats 7
    def wrap_sort(func=Search.sort):
        def wrapper(self, *keys):
            new_keys = map(lambda k: k if k is not "offset" else "log.offset", keys)
            return func(self, *new_keys)

        return wrapper

    def wrap_filter(func=Search.filter):
        def wrapper(self, *args, **kwargs):
            new_kwargs = {(k if k is not "offset" else "log.offset"): v for k, v in kwargs.items()}
            return func(self, *args, **new_kwargs)

        return wrapper

    Search.sort = wrap_sort()
    Search.filter = wrap_filter()


patch_airflow()
