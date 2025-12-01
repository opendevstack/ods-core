
{{/*
Part of the ODS helm tpl library

Version: 1.0
*/}}

{{/*
Create an image name from the registry, image path, name and tag.
.Values.registry, .Values.imageNamespace, .Values.componentId and .Values.imageTag are injected by the ODS pipeline on deployment.
If not set, values from .Values.image.registry, .Values.image.path, .Values.image.name and .Values.image.tag are used.
*/}}
{{- define "image.fullname" -}}
{{- if (or .Values.registry .Values.image.registry) }}
{{- printf "%s/%s/%s:%s" (or .Values.registry .Values.image.registry) (or .Values.imageNamespace .Values.image.path) (or .Values.componentId .Values.image.name) (or .Values.imageTag .Values.image.tag | toString) -}}
{{- else }}
{{- printf "%s/%s:%s" (or .Values.imageNamespace .Values.image.path) (or .Values.componentId .Values.image.name) (or .Values.imageTag .Values.image.tag ) -}}
{{- end }}
{{- end }}
