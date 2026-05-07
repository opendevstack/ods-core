{{/* Application domain: application-owned runtime config and secrets */}}
{{- define "chart.applicationConfigData" }}
ODS_API_SERVICE_DB_DATASOURCE_URL: "jdbc:postgresql://{{ include "chart.fullname" . }}-postgresql:5432/{{ .Values.postgresql.databaseName }}"
{{- end }}

{{- define "chart.applicationSecretData" }}
ODS_API_SERVICE_DB_NAME: {{ .Values.postgresql.databaseNameB64 }}
ODS_API_SERVICE_DB_USER: {{ .Values.postgresql.databaseUserB64 }}
ODS_API_SERVICE_DB_PASSWORD: {{ .Values.postgresql.databasePasswordB64 }}
AZURE_TENANT_ID: {{ .Values.spring.security.obo.azureTenant | b64enc | quote }}
OBO_TOKEN_URL: {{ .Values.spring.security.obo.tokenUrl | b64enc | quote }}
OBO_CLIENT_ID: {{ .Values.spring.security.obo.clientId | b64enc | quote }}
OBO_CLIENT_SECRET: {{ .Values.spring.security.obo.clientSecret | b64enc | quote }}
{{- end }}
