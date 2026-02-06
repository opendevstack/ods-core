# ODS Quickstarters Tests

This repository contains the Jenkins pipelines needed to execute tests for ODS quickstarters in a generic, environment-agnostic way.


## Architecture

The solution use:

1. **Jenkinsfile-create-jobs**: Pipeline to create Jenkins jobs from quickstarter repositories
2. **Jenkinsfile-qs**: Individual quickstarter test pipeline (called by created jobs)

## Setup Instructions

Follow this sequence to set up and run quickstarter tests:

### Step 1: Create the Managed Configuration File

1. Go to **Manage Jenkins** → **Managed files**.
2. Add a new **Custom file** with ID `quickstarter-test-config`.
3. Copy the contents of `quickstarter-test.env.template` and replace the values with your environment-specific values.

### Step 2: Create and Run the Job Creation Pipeline

1. Create a Jenkins pipeline job pointing to `Jenkinsfile-create-jobs`.
2. Execute the job and provide the URL of the repository to be tested when prompted.
3. If the job fails due to script permissions, fix the execution permissions in your Jenkins instance and re-run.
4. Select the branches you want to process in the interactive prompt.

After completion, you will get a folder per repository and a subfolder per branch. Inside each branch folder you will find one job per quickstarter and a job to run them all. If you do not want a quickstarter to run, disable its job.

## Configuration File

The managed configuration file (`quickstarter-test-config`) contains environment-specific parameters in `.env` format:

```bash
# Bitbucket/Git Configuration
BITBUCKET_URL=https://bitbucket-myproject-cd.apps.example.com

# OpenShift/Kubernetes Configuration
OPENSHIFT_APPS_BASEDOMAIN=apps.example.com

# Project/Namespace Configuration
ODS_PROJECT=myproject
ODS_NAMESPACE=ods

# Credentials Configuration
CREDENTIALS_ID_PATTERN=myproject-cd-cd-user-with-password
CREDENTIALS_TOKEN_ID_PATTERN=myproject-cd-cd-user-token

# Git Repository References
ODS_CORE_BRANCH=master
ODS_CONFIGURATION_BRANCH=master
ODS_GIT_REF=master

# Docker Registry
DOCKER_REGISTRY=docker-registry.default.svc:5000

# Sonar Configuration
SONAR_QUALITY_PROFILE=Sonar way
SONAR_QUALITY_GATE=ODS Default Quality Gate
```

## Updating Configuration

To update the configuration for a different environment, update the managed file `quickstarter-test-config` with the new values.

## Template File

A template file (`quickstarter-test.env.template`) is provided as a reference showing all available configuration parameters with examples and descriptions.

## Credentials

The pipelines expect Jenkins credentials to be configured with IDs following the pattern:
- `${ODS_PROJECT}-cd-cd-user-with-password`: Username/password credentials
- `${ODS_PROJECT}-cd-cd-user-token`: Token-based credentials

These credentials must be created in Jenkins before running the test pipelines.

## Files

- **Jenkinsfile-create-jobs**: Job creation pipeline
- **Jenkinsfile-qs**: Individual quickstarter test pipeline
- **quickstarter-test.env.template**: Configuration template reference
- **scripts/create_jobs.sh**: Script to create Jenkins jobs
- **scripts/job_template.xml**: XML template for Jenkins jobs
- **scripts/run_all.xml**: XML template to run all the Jenkins jobs in a folder
