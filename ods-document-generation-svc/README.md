# ODS Document Generation Service

The [ODS document generation](https://github.com/opendevstack/ods-document-generation-svc) service that transforms document templates in a remote Bitbucket repository into PDF documents, used from the Release manager quickstarter.

# Setup

The OpenShift templates are located in `openshift` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd openshift && tailor status -l app=ods-doc-gen-svc -n cd` to see if there is any drift between current and desired state.

To deploy the doc gen service in the `cd` namespace run `tailor apply --namespace cd` form within the `ods-core/ods-document-generation-svc/openshift` directory.
