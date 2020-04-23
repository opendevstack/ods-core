# Provisioning App

Nexus is a repository manager. It allows you to proxy, collect, and manage your dependencies so that you are not constantly juggling a collection of artifacts. In essence. it makes it easy to distribute your software.

# Setup

The OpenShift templates are located in `oc-config` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd ocp-config && tailor status -l app=prov-app -n cd` to see if there is any drift between current and desired state.

To deploy the provisiong app in the `cd` namespace run `tailor apply --namespace cd` form within the `ods-core/provisioning-app/ocp-config` directory.
