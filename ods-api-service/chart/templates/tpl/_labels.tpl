{{/*
Part of the ODS helm tpl library

Version: 1.0
*/}}


{{- define "common.matchLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
