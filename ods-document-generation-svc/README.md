# ODS Document Generation Service

The [ODS document generation](https://github.com/opendevstack/ods-document-generation-svc) service that transforms document templates in a remote Bitbucket repository into PDF documents, used from the Release manager quickstarter.

# Setup

The OpenShift templates are located in `ocp-config` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd ocp-config && tailor status -l app=ods-doc-gen-svc -n ods` to see if there is any drift between current and desired state.

To install the doc gen service, run `make install-doc-gen`.
