# SonarQube

SonarQube is an open source platform developed by SonarSource for continuous inspection of code quality to perform automatic reviews with static analysis of code to detect bugs, code smells, and security vulnerabilities.

This repo contains the build recipe for a central SonarQube instance to which all Jenkins instances send reports to. The remainder of this readme describes how that setup is done.
If you are looking for instructions how to analyse your repositories, please see [USAGE.md](https://github.com/opendevstack/ods-core/blob/master/USAGE.md).

## Setup

The OpenShift templates are located in `ocp-config` and can be compared with the OC cluster using [tailor](https://github.com/opendevstack/tailor). For example, run `cd ocp-config && tailor status` to see if there is any drift between current and desired state.

## Administration

There is an `admin` user which is allowed to change settings, install plugins, etc. The password is located in the OC project `cd`, under the `sonarqube-app` secrets.

## Building a new image

Push to this repository, then go to the build config in OC and start a new build.

## Manual steps performed after booting the instance

1. Admin password changed (see OC secrets `sonarqube-app`).
2. Locked Sonarqube to logged-in users (Administation > Configuration > Security > Force User Authentication).
3. Logged in as cd_user and created a auth token (My Account > Security > Generate New Token).
4. As the auth token and the admin password has changed, you will need to update the OCP configuration again.
5. Installed further plugins (Administation > Marketplace), e.g. SonarJava, SonarJS, Git.
