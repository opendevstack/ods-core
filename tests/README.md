# ODS Core - tests

This packages houses the test infrastructure for ODS core components, yet also makes use of tests located within specific ODS core components (e.g. `sonarqube/test.sh`)

## Types of tests
1. Multi layer tests to verify the creation of a new project [in create-projects](create-projects)
1. Verification of the installation of ODS [in ods-verify](ods-verify)
1. Tests for quickstarters - the exact instructions are located in [ods-quickstarters](https://github.com/opendevstack/ods-quickstarters/tree/master)

## Prerequisites
1. [Golang](https://golang.org/doc/install) installed
1. the user you are logged into Openshift with needs to have cluster admin rights
1. the Provisioning Application needs to be configured to allow project deletion! This is done in 
`ods-core.env` thru setting `PROV_APP_PROVISION_CLEANUP_INCOMPLETE_PROJECTS_ENABLED=true`. In order to have this setting applied, you need to update `ods-core.env` and run `tailor apply` to ensure no diff between the config and the deployed version!
1. the configured `CD_USER_ID` in `ods-core.env` must have rights to create projects on the entire stack.
1. have an atlassian user at hand with `admin` privileges, such as `openshift` - you'll need it to run the tests below.

These settings can be reverted / set to false after the run of the tests in `ods-core` and in `ods-quickstarters`.

## Running the core tests
Rn `make test` [in this directory](Makefile). To pass a different Atlassian user than the standard one (`openshift:openshift`), specify the credentials as param for `make`, e.g. `make BASIC_AUTH_CREDENTIAL="user:password" test`.

## Running the quickstarter tests
Run `make test-quickstarter` [in this directory](Makefile). By default, this will test all quickstarters in `ods-quickstarters` located next to `ods-core`. You can run just one specific quickstarter test with `make test-quickstarter QS=be-golang-plain` or run tests located in a custom directory like this: `make test-quickstarter QS=my-quickstarters/...` or `make test-quickstarter QS=my-quickstarters/foobar`

## Authoring quickstarter tests
Quickstarters must have a `testdata` directory, which needs to contain a `steps.yml` file describing which test steps to execute in YAML format. The allowed fields are defined by https://pkg.go.dev/github.com/opendevstack/ods-core/tests/quickstarter. Typically, the `testdata` directory will also contain a `golden` folder with JSON files describing the expected results. See https://github.com/opendevstack/ods-quickstarters/tree/master/be-golang-plain/testdata as an example.
