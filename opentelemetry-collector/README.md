# Opentelemetry Collector

The OpenTelemetry Collector is a vendor-agnostic way to receive, process, and export telemetry data. It supports various data formats and protocols, making it easy to collect and distribute your observability data.

## Setup

The OpenShift templates are located in the chart directory and can be compared with the OC cluster using Helm. For example, run cd chart && helm secrets diff upgrade to see if there is any drift between the current and desired state.

To install the OpenTelemetry Collector, run:

`helm install opentelemetry-collector .`

## Configuration

All the relevant configuration of the Opentelemetry Collector is store in the config map named collector-config in the same namespace where is running the pod.

## Building a new image

Push to this repository, then go to the build config in OC and start a new build.

Aditionally you can run `make start-opentelemetry-collector-build`.

