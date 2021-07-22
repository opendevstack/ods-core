# ODS Core - tests

This packages houses the test infrastructure for ODS core components, yet also makes use of tests located within specific ODS core components (e.g. `sonarqube/test.sh`)

## Types of tests
1. Multi-layer tests to verify the creation of a new project [in create-projects](create-projects)
1. Verification of an ODS installation [in ods-verify](ods-verify)
1. Smoketests to verify crucial functionality of an ODS installation [in smoketest](smoketest)
1. Tests for quickstarters - the exact instructions are located in [ods-quickstarters](https://github.com/opendevstack/ods-quickstarters/tree/master)

## Prerequisites
1. [Golang](https://golang.org/doc/install) installed
1. the user you are logged into OpenShift needs to have the `self-provisioner` role
1. for the smoke tests, the provisioning application needs to be configured to allow project deletion. This is done in `ods-core.env` thru setting `PROV_APP_PROVISION_CLEANUP_INCOMPLETE_PROJECTS_ENABLED=true`. In order to have this setting applied, you need to update `ods-core.env` and run `make apply-provisioning-app-deploy` to ensure no diff between the config and the deployed version exists.
1. the configured `CD_USER_ID` in `ods-core.env` must have rights to create projects on the entire stack.
1. have an atlassian user at hand with `admin` privileges, such as `openshift` - you'll need it to run the tests below.
1. In case you're working in a corporative environment you should set the env vars: http_proxy, https_proxy, HTTP_PROXY, HTTPS_PROXY, no_proxy and NO_PROXY
1. Is mandatory to have installed jq cli also

These settings can be reverted / set to false after the run of the tests in `ods-core` and in `ods-quickstarters`.

## Running the core tests
Run `make test` [in this directory](Makefile), which will execute project creation tests, verification and smoketests. To pass a different Atlassian user than the standard one (`openshift:openshift`), specify the credentials as param for `make`, e.g. `make BASIC_AUTH_CREDENTIAL="user:password" test`.

## Running the quickstarter tests
Run `make test-quickstarter` [in this directory](Makefile). By default, this will test all quickstarters in `ods-quickstarters` located next to `ods-core`. You can run just one specific quickstarter test with `make test-quickstarter QS=be-golang-plain` or run tests located in a custom directory like this: `make test-quickstarter QS=my-quickstarters/...` or `make test-quickstarter QS=my-quickstarters/foobar`. By default all tests run sequentially. To run some in parallel, use e.g. `make test-quickstarter PARALLEL=3`.

## Authoring quickstarter tests
Quickstarters must have a `testdata` directory, which needs to contain a `steps.yml` file describing which test steps to execute in YAML format. The allowed fields are defined by https://pkg.go.dev/github.com/opendevstack/ods-core/tests/quickstarter. Typically, the `testdata` directory will also contain a `golden` folder with JSON files describing the expected results. See https://github.com/opendevstack/ods-quickstarters/tree/master/be-golang-plain/testdata as an example.
