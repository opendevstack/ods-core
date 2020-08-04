# ODS Core - tests

This packages houses the test infrastructure for ODS core components, yet also makes use of tests located within specific ODS core components (e.g. `sonarqube/test.sh`)

## Types of tests
1. Multi layer tests to verify the creation of a new project [in create-projects](create-projects)
1. Verification of the installation of ODS [in ods-verify](ods-verify)

**Attention:** Tests for the quickstarters, located in [ods-quickstarters/tests](https://github.com/opendevstack/ods-quickstarters/tree/master/tests),
depend on projects created thru tests here!<br>Secondly, there is a few musts for these tests to run:
1. the user you are logged into Openshift with needs to have `cluster admin rights`
1. the Provision Application needs to be configured to allow project deletion! This is done in 
`ods-core.env` thru setting `PROV_APP_PROVISION_CLEANUP_INCOMPLETE_PROJECTS_ENABLED=true`. In order to have this setting applied, you need to update `ods-core.env` and run `tailor apply` to ensure no diff between the config and the deployed version!
1. the configured `CD_USER_ID` in `ods-core.env` must have rights to create projects on the entire stack.

These settings can be reverted / set to false after the run of the tests in `ods-core` and in `ods-quickstarters`.

## Running the tests
just run `make test` [in this directory](Makefile)
