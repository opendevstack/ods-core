# Provisioning App

The [Provisioning App](https://github.com/opendevstack/ods-provisioning-app) creates new OpenDevStack digital projects. It is the central entrypoint to get started with a new project / or provision new components based on quickstarters.

# Setup

The OpenShift templates are located in `ocp-config` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd ocp-config && tailor status -l app=ods-provisioning-app -n ods` to see if there is any drift between current and desired state.

To install the provisiong app, run `make install-provisioning-app`.
