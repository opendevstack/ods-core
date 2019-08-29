# AirFlow OpenDevStack Shared Image

This image provides AirFlow 1.10.3 for OpenShift. 

## Setup

The AirFlow setup that this image provides is based on the KubernetesExecutor and will
start worker pods on demand. It is also setup to use an ElasticSearch instance as the log
repository for all workers. As illustrated bellow:

![Airflow Architecture](Airflow Architecture Diagram.png?raw=true "Airflow Architecture")

To setup the whole infrastructure the Airlfow QuickStarter should be used.

## Contents

The image contains all dependencies and Airflow extras to run Airflow 1.10.3 in this setup.
It also includes FileBeat 7.0.0 to send all log files to ElasticSearch

### Generic OAuth backend

A generic OAuth backend is included in this image to enabled Airflow to
authenticate against any OAuth server including the one from OpenShift

### OpenShift Plugin

An OpenShift Plugin was added to address compatibility and security issues
between the Kubernetes Executor and Openshift.

This plugin includes two views.

* One for inspecting the pods that are and/or were part of the cluster
* A second one to sync DAG information from the worker image back to 
the webserver and scheduler

## Security

### Authentication

The authentication method is enabled and uses OpenShift OAuth to authenticate
users in the WebServer.

## Configuration

None Airflow configuration options were changed and they can be used as documented
in the [Airflow Documentation](https://airflow.apache.org/project.html)

Besides all Airflow configuration, the OAuth backend and the OpenShift Plugin
include a small set of configuration.

#### OAuth configuration

The configuration section is `oauth` and must have the followin keys:

```ini
[oauth]
# base_url contains alwayes the value of the OpenShift API url 
base_url = https://your.openshift.api.url

# client_id must have the service account name which serves as OAuth client
client_id = system:serviceaccount:your-namespace:your-service-account-name


# oauth_callback_route should not change unless you know what you are doing
oauth_callback_route = /oauth2callback

# authorize_url authorization api of OpenShift. 
authorize_url = https://your.openshift.api.url/oauth/authorize

# access_token_url token api of OpenShift.
access_token_url = https://your.openshift.api.url/oauth/token

# access_token_method Method which should be used for calling the API
access_token_method = POST

# user_info_url User information API of OpenShift
user_info_url = https://your.openshift.api.url/apis/user.openshift.io/v1/users/~

# username_key and email_key are path inside the reply of user_info_url where
# the username and email of the user can be found  
username_key = metadata.name
email_key = metadata.name

# oauth_permission_backend The OAuth authorization backend
oauth_permission_backend=airflow_oauth.contrib.auth.backends.openshift_permission_backend
```

### OpenShift Plugin Settings

The section `openshift_plugin` supports the plugin and must have the followin keys:

```ini
[openshift_plugin]
# OpenShift roles of an user which will allow access to Airflow
access_roles=role1,role2
# OpenShift roles of an user which will allow superuser access to Airflow
superuser_roles=role1
# Base OpenShift console url for build the links to airflow resources
openshift_console_url=https://localhost
```

## Environemnt Variables 

A set of Environment Variables where included to allow a easy way of using Config Maps
and Secrets. They are:

| Name | Type | Description|
|-----|------|------------|
|**AIRFLOW_COMMAND**| String (Required) | Airflow command that should be executed or empty for a custom commands. It will define if the container will behave as the webserver, schediler and so on.  The availabled options are: 'webserver', 'worker', 'scheduler', 'flower' or 'version' |
|POSTGRES_HOST| String (Required) | Postgresql host to which Airflow should connect |
|POSTGRES_PORT|String| Postgresql port to which Airflow should connect. Default: 5432 |
|POSTGRES_USER|String (Required) | Postgresql username which Airflow should use |  
|POSTGRES_PASSWORD|String (Required)| Postgresql password which Airflow should use |  
|POSTGRES_DATABASE|String| Database name that should be used. Default: airflow|
|START_FILE_BEAT| 1 or 0 | 0 if FileBeat service should not be started. Default: 1 (it should be stared) |
|ELASTICSEARCH_URL| URL | ElasticSearch url to which Airflow should connect|
|ELASTICSEARCH_USERNAME| String | ElasticSearch username which Airflow should use |
|ELASTICSEARCH_PASSWORD| String | ElasticSearch password which Airflow should use |

 
Since multiple deployment configs will use the same configuration and the values, besides
the `AIRFLOW_COMMAND`, it is advisable to create a config map and mount it to each
Airflow deployment config.   
 
**All Airflow configuration, including OpenShift Plugin configuration,
can be done using environment variables** as documented in
https://airflow.apache.org/howto/set-config.html.

