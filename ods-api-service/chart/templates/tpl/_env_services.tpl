{{/* Services domain: internal service APIs and service-specific settings */}}
{{- define "chart.servicesConfigData" }}
SERVICE_PROJECT_LDAP_GROUP_PATTERN: {{ .Values.services.project.ldap.group.pattern | quote }}
{{ if .Values.apis.projectUsers.enabled }}
API_PROJECT_USERS_WORKFLOW_NAME: {{ .Values.apis.projectUsers.workflowName | quote }}
API_PROJECT_USERS_TOKEN_EXPIRATION_HOURS: {{ .Values.apis.projectUsers.token.expirationHours | quote }}
{{ end }}
{{ if .Values.apis.projects.enabled }}
API_PROJECTS_MINIEDP_PROVISION_WORKFLOW_NAME: {{ .Values.apis.projects.workflowName | quote }}
API_PROJECTS_LOCATIONS: {{ .Values.apis.projects.locations | quote }}
{{ end }}
{{- end }}

{{- define "chart.servicesSecretData" }}
{{ if .Values.apis.projectUsers.enabled }}
API_PROJECT_USERS_TOKEN_SECRET: {{ .Values.apis.projectUsers.token.secret | b64enc | quote }}
{{ end }}
{{- end }}