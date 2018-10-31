# Jenkins Webhook Proxy

Provides one endpoint accepting webhooks from BitBucket and forwards them to the
corresponding Jenkins pipeline (which is determined based on the branch name).
If there is no corresponding pipeline yet, it will be created on the fly. Once a
branch is deleted or a pull request declined/merged, the corresponding Jenkins
pipeline is deleted as well.

## Usage

Go to "Repository Settings > Post Webhooks" and click on "Add webhook". Enter
`Jenkins` as Title and the route URL (see following [Setup](#setup) section) as
URL. Under "Repository events", select `On push` and `Branch deleted`. Under
"Pull request events", select `Pull request merged` and `Pull request declined`.
Save your changes and you're done! Any other webhooks already setup to trigger
Jenkins are not needed anymore and should be deactivated or deleted.

## Setup

Run `tailor update` in `ocp-config`. This will create `BuildConfig` and
`ImageStream` in the central `cd` namespace. Next, you will have to create a
`DeploymentConfig`, `Service` and `Route` in the namespace your Jenkins instance
runs.

## Development

See the `Makefile` targets.
