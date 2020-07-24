# ODS Core - tests

This packages houses the test infrastructure for ODS core components, yet also makes use of tests located within specific ODS core components (e.g. `sonarqube/test.sh`)

## Types of tests
1. Multi layer tests to verify the creation of a new project [in create-projects](create-projects)
1. Verification of the installation of ODS [in ods-verify](ods-verify)

**Attention:** Tests for the quickstarters, located in [ods-quickstarters/tests](https://github.com/opendevstack/ods-quickstarters/tree/master/tests),
depend on projects created thru tests here!

## Running the tests
just run `make test` [in this directory](Makefile)
