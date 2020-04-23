# Provisioning App

The [Provisioning App](https://github.com/opendevstack/ods-provisioning-app) creates new OpenDevStack digital projects. It is the central entrypoint to get started with a new project / or provision new components based on quickstarters.

# Setup

The OpenShift templates are located in `oc-config` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd ocp-config && tailor status -l app=prov-app -n cd` to see if there is any drift between current and desired state.

To deploy the provisiong app in the `cd` namespace run `tailor apply --namespace cd` form within the `ods-core/provisioning-app/ocp-config` directory.
