{{/*
Part of the ODS helm tpl library

Version: 1.0
*/}}


{{/*
Pod affinity/anti-affinity (soft)

Usage: Include where needed, e.g.
````
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      affinity:
        podAntiAffinity: {{- include "common.affinities.pods.soft" . | nindent 10}}
````
*/}}
{{- define "common.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - weight: 1
    podAffinityTerm:
      labelSelector:
        matchLabels: {{- include "common.matchLabels" . | nindent 10 }}
      topologyKey: "kubernetes.io/hostname"
{{- end -}}

{{/*
Pod affinity/anti-affinity (hard)

Usage: Include where needed, e.g.
````
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      affinity:
        podAntiAffinity: {{- include "common.affinities.pods.hard" . | nindent 10}}
````
*/}}
{{- define "common.affinities.pods.hard" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- include "common.matchLabels" . | nindent 10 }}
      topologyKey: "kubernetes.io/hostname"
{{- end -}}
