# SonarQube

SonarQube is an open source platform developed by SonarSource for continuous inspection of code quality to perform automatic reviews with static analysis of code to detect bugs, code smells, and security vulnerabilities.

This repo contains the build recipe for a central SonarQube instance to which all Jenkins instances send reports to.

## Setup

The OpenShift templates are located in `chart` and can be compared with the OC cluster using [helm](https://github.com/helm/helm). For example, run `cd chart && helm secrets diff upgrade` to see if there is any drift between current and desired state.

## Administration

There is an `admin` user which is allowed to change settings, install plugins, etc. The password is located in the OC project `ods`, under the `sonarqube-app` secrets.

## Building a new image

Push to this repository, then go to the build config in OC and start a new build.

## Manual steps performed after booting the instance

1. Admin password changed (see OC secrets `sonarqube-app`).
2. Locked Sonarqube to logged-in users (Administation > Configuration > Security > Force User Authentication).
3. Logged in as cd_user and created a auth token (My Account > Security > Generate New Token).
4. As the auth token and the admin password has changed, you will need to update the OCP configuration again.
5. Installed further plugins (Administation > Marketplace), e.g. SonarJava, SonarJS, Git.
