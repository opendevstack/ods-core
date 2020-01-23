# Setup ODS DEV ENV
The goal of this project is facilitating a quick and consistent setup of an ODS development environment on a local VM or AWS VM outside of the BI network.
Starting from a fresh Ubuntu 16.04 LTS installation, the provided shell scripts will install all required dependencies, configure the host system, start an OpenShift cluster, and create the ODS application on the OpenShift cluster, including a basic installation of the Atlassion suite.
Most of the logic was pulled together from the github workflow continuous-integration-workflow.yml and other scripts in this repository.

## Usage
- Preparation: Setup a fresh Ubuntu 16.04 LTS host, including a git installation.
- Checkout the ods-core repository from github, available here: https://github.com/opendevstack/ods-core
- Run the script ods-core/infrastructure-setup-devenv/setup-dev-environment-step1.sh to setup all dependencies and configure Ubuntu 16.04
- Logout your user and login again to let changes made by the script take effect (Compare Issue list below)
- Run the script ods-core/infrastructure-setup-devenv/setup-dev-environment-step2.sh to install an OpenShift cluster and setup the ODS application

## Issues
- During docker setup, the current user will be added the group *docker* so the docker command can be executed without sudo on the user's behalf, which is a requirement for a successful OpenShift setup. To make this configuration take effect, the user is required to logout and login again. Maybe, a workaround can be found to support an easier setup workflow.
- Currently, the setup will only work with Ubuntu 16.04 LTS. Experiments to make it work on CentOS7, CentOS8 or Ubuntu 18.04 have not been successful so far.
- Currently, after starting up the OpenShift cluster, the web console may not be available on the first try. This issue still has to be resolved. Working with the OpenShift cluster will be possible using the oc cli tools.
