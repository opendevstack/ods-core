{{/* Application domain: application-owned runtime config and secrets */}}
{{- define "chart.applicationConfigData" }}
ODS_API_SERVICE_DB_DATASOURCE_URL: "jdbc:postgresql://{{ include "chart.fullname" . }}-postgresql:5432/{{ .Values.postgresql.databaseName }}"
{{- end }}

{{- define "chart.applicationSecretData" }}
ODS_API_SERVICE_DB_NAME: {{ .Values.postgresql.databaseNameB64 }}
ODS_API_SERVICE_DB_USER: {{ .Values.postgresql.databaseUserB64 }}
ODS_API_SERVICE_DB_PASSWORD: {{ .Values.postgresql.databasePasswordB64 }}
{{- end }}
