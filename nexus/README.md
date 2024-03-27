# Nexus

Nexus is a repository manager. It allows you to proxy, collect, and manage your dependencies so that you are not constantly juggling a collection of artifacts. In essence. it makes it easy to distribute your software.

## Setup

The OpenShift templates are located in `chart` and can be compared with the OC cluster using [Helm](https://github.com/helm/helm). For example, run `cd chart && helm secrets diff upgrade` to see if there is any drift between current and desired state.

To install Nexus, run `make install-nexus`.

## Administration

There is an `admin` user which is allowed to change settings, install plugins, etc. The password is located in the OC project `ods`, under the `nexus-app` secrets.

## Building a new image

Push to this repository, then go to the build config in OC and start a new build.

Aditionally you can run `make start-nexus-build`.

## Manual steps performed after booting the instance

1. Admin password changed (see OC secrets `sonarqube-app`).
2. Anonymous access to Nexus removed.
3. Blob stores created e.g docker, leva-documentation, releases, etc.
4. Repositories created e.g docker-group, leva-documentation, pypi-all, etc.
5. Developer account created.