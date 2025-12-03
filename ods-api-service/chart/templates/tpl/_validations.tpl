{{/*
Validation helpers for required values
*/}}

{{/*
Validate AAP credentials when enabled
*/}}
{{- define "chart.validate.aap" -}}
{{- if .Values.externalServices.aap.enabled }}
  {{- if not .Values.externalServices.aap.baseUrl }}
    {{- fail "externalServices.aap.baseUrl is required when aap is enabled" }}
  {{- end }}
  {{- if not .Values.externalServices.aap.username }}
    {{- fail "externalServices.aap.username is required when aap is enabled" }}
  {{- end }}
  {{- if not .Values.externalServices.aap.password }}
    {{- fail "externalServices.aap.password is required when aap is enabled" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Validate UIPath credentials when enabled
*/}}
{{- define "chart.validate.uipath" -}}
{{- if .Values.externalServices.uipath.enabled }}
  {{- if not .Values.externalServices.uipath.host }}
    {{- fail "externalServices.uipath.host is required when uipath is enabled" }}
  {{- end }}
  {{- if not .Values.externalServices.uipath.clientId }}
    {{- fail "externalServices.uipath.clientId is required when uipath is enabled" }}
  {{- end }}
  {{- if not .Values.externalServices.uipath.clientSecret }}
    {{- fail "externalServices.uipath.clientSecret is required when uipath is enabled" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Validate Project Users API configuration when enabled
*/}}
{{- define "chart.validate.projectUsers" -}}
{{- if .Values.apis.projectUsers.enabled }}
  {{- if not .Values.apis.projectUsers.workflowName }}
    {{- fail "apis.projectUsers.workflowName is required when projectUsers is enabled" }}
  {{- end }}
  {{- if not .Values.apis.projectUsers.token.secret }}
    {{- fail "apis.projectUsers.token.secret is required when projectUsers is enabled (minimum 256 bits / 32 characters)" }}
  {{- end }}
  {{- if lt (len .Values.apis.projectUsers.token.secret) 32 }}
    {{- fail "apis.projectUsers.token.secret must be at least 32 characters (256 bits) for JWT signing" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Validate Projects Info Service configuration when enabled
*/}}
{{- define "chart.validate.projectsInfoService" -}}
{{- if .Values.externalServices.projectsInfoService.enabled }}
  {{- if not .Values.externalServices.projectsInfoService.baseUrl }}
    {{- fail "externalServices.projectsInfoService.baseUrl is required when projectsInfoService is enabled" }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Validate OpenShift instances configuration
*/}}
{{- define "chart.validate.openshift" -}}
{{- range .Values.externalServices.openshift.instances }}
  {{- if not .name }}
    {{- fail "name is required for each OpenShift instance" }}
  {{- end }}
  {{- if not .apiUrl }}
    {{- fail (printf "apiUrl is required for OpenShift instance '%s'" .name) }}
  {{- end }}
  {{- if not .token }}
    {{- fail (printf "token is required for OpenShift instance '%s'" .name) }}
  {{- end }}
  {{- if not .namespace }}
    {{- fail (printf "namespace is required for OpenShift instance '%s'" .name) }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Validate Bitbucket instances configuration
*/}}
{{- define "chart.validate.bitbucket" -}}
{{- range .Values.externalServices.bitbucket.instances }}
  {{- if not .name }}
    {{- fail "name is required for each Bitbucket instance" }}
  {{- end }}
  {{- if not .baseUrl }}
    {{- fail (printf "baseUrl is required for Bitbucket instance '%s'" .name) }}
  {{- end }}
  {{- if and (not .bearerToken) (and (not .username) (not .password)) }}
    {{- fail (printf "either bearerToken or username+password is required for Bitbucket instance '%s'" .name) }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Run all validations
*/}}
{{- define "chart.validate.all" -}}
{{- include "chart.validate.aap" . }}
{{- include "chart.validate.uipath" . }}
{{- include "chart.validate.projectUsers" . }}
{{- include "chart.validate.projectsInfoService" . }}
{{- include "chart.validate.openshift" . }}
{{- include "chart.validate.bitbucket" . }}
{{- end -}}
