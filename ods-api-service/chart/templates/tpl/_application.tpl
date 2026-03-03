{{/*
Template for generating application.yaml dynamically from values
*/}}
{{- define "chart.application.yaml" -}}
server:
  port: 8080

logging:
  level:
{{- range $key, $value := .Values.config.logging.level }}
    {{ $key }}: {{ $value }}
{{- end }}

spring:
  profiles:
    active: {{ .Values.env.SPRING_PROFILES_ACTIVE }}

management:
  endpoints:
    web:
      exposure:
        include: {{ .Values.config.management.endpoints.web.exposure.include }}
{{- if .Values.config.management.endpoint }}
  endpoint:
{{ toYaml .Values.config.management.endpoint | nindent 4 }}
{{- end }}
{{- if .Values.config.management.info }}
  info:
{{ toYaml .Values.config.management.info | nindent 4 }}
{{- end }}
{{- if .Values.config.management.httpexchanges }}
  httpexchanges:
{{ toYaml .Values.config.management.httpexchanges | nindent 4 }}
{{- end }}

{{- if .Values.config.springdoc }}
springdoc:
{{ toYaml .Values.config.springdoc | nindent 2 }}
{{- end }}

openapi:
  info:
    title: {{ .Values.config.openapi.info.title | quote }}
    description: {{ .Values.config.openapi.info.description | quote }}
    version: {{ .Values.config.openapi.info.version | quote }}
    contact:
      name: {{ .Values.config.openapi.info.contact.name | quote }}
      email: {{ .Values.config.openapi.info.contact.email | quote }}
{{- if .Values.config.openapi.servers }}
  servers:
{{- range .Values.config.openapi.servers }}
    - url: {{ .url | quote }}
      description: {{ .description | quote }}
{{- end }}
{{- end }}

{{- if .Values.config.app }}
# Declarative Security Configuration
app:
{{ toYaml .Values.config.app | nindent 2 }}
{{- end }}

{{- if .Values.config.otel }}
otel:
{{ toYaml .Values.config.otel | nindent 2 }}
{{- end }}

# External Service Configuration
{{- if .Values.externalServices.aap.enabled }}
automation:
  platform:
    ansible:
      enabled: true
      base-url: ${ANSIBLE_BASE_URL}
      username: ${ANSIBLE_USERNAME}
      password: ${ANSIBLE_PASSWORD}
      timeout: ${ANSIBLE_TIMEOUT}
      ssl:
        verify-certificates: ${ANSIBLE_SSL_VERIFY:true}
        trust-store-path: ${ANSIBLE_SSL_TRUSTSTORE_PATH:}
        trust-store-password: ${ANSIBLE_SSL_TRUSTSTORE_PASSWORD:}
        trust-store-type: ${ANSIBLE_SSL_TRUSTSTORE_TYPE:JKS}
{{- end }}

{{- if .Values.externalServices.uipath.enabled }}
    uipath:
      host: ${UIPATH_HOST}
      clientId: ${UIPATH_CLIENT_ID}
      clientSecret: ${UIPATH_CLIENT_SECRET}
      tenancy-name: ${UIPATH_TENANCY_NAME}
      organization-unit-id: ${UIPATH_ORGANIZATION_UNIT_ID}
      login-endpoint: {{ .Values.externalServices.uipath.loginEndpoint }}
      queue-items-endpoint: {{ .Values.externalServices.uipath.queueItemsEndpoint }}
      timeout: ${UIPATH_TIMEOUT}
      ssl:
        verify-certificates: ${UIPATH_SSL_VERIFY:true}
        trust-store-path: ${UIPATH_SSL_TRUSTSTORE_PATH:}
        trust-store-password: ${UIPATH_SSL_TRUSTSTORE_PASSWORD:}
        trust-store-type: ${UIPATH_SSL_TRUSTSTORE_TYPE:JKS}
{{- end }}

{{- if .Values.apis.projectUsers.enabled }}
apis:
  project-users:
    ansible-workflow-name: ${API_PROJECT_USERS_WORKFLOW_NAME}
    token:
      secret: ${API_PROJECT_USERS_TOKEN_SECRET}
      expiration-hours: ${API_PROJECT_USERS_TOKEN_EXPIRATION_HOURS}
{{- end }}

externalservices:
{{- if gt (len .Values.externalServices.openshift.instances) 0 }}
  openshift:
    instances:
{{- range .Values.externalServices.openshift.instances }}
      {{ .name }}:
        api-url: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_API_URL}
        token: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_TOKEN}
        namespace: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_NAMESPACE}
        connection-timeout: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT}
        read-timeout: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_READ_TIMEOUT}
        trust-all-certificates: ${OPENSHIFT_{{ .name | upper | replace "-" "_" }}_TRUST_ALL}
{{- end }}
{{- end }}

{{- if gt (len .Values.externalServices.bitbucket.instances) 0 }}
  bitbucket:
    instances:
{{- range .Values.externalServices.bitbucket.instances }}
      {{ .name }}:
        base-url: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_BASE_REST_URL}
{{- if .bearerToken }}
        bearer-token: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_BEARER_TOKEN}
{{- else }}
        username: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_USERNAME:}
        password: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_PASSWORD:}
{{- end }}
        connection-timeout: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT}
        read-timeout: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_READ_TIMEOUT}
        trust-all-certificates: ${BITBUCKET_{{ .name | upper | replace "-" "_" }}_TRUST_ALL}
{{- end }}
{{- end }}

{{- if gt (len .Values.externalServices.webhookProxy.clusters) 0 }}
  webhook-proxy:
    clusters:
{{- range .Values.externalServices.webhookProxy.clusters }}
      {{ .name }}:
        cluster-base: ${WEBHOOK_PROXY_{{ .name | upper | replace "-" "_" }}_CLUSTER_BASE}
        connection-timeout: ${WEBHOOK_PROXY_{{ .name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT}
        read-timeout: ${WEBHOOK_PROXY_{{ .name | upper | replace "-" "_" }}_READ_TIMEOUT}
        trust-all-certificates: ${WEBHOOK_PROXY_{{ .name | upper | replace "-" "_" }}_TRUST_ALL}
        default-jenkinsfile-path: ${WEBHOOK_PROXY_{{ .name | upper | replace "-" "_" }}_JENKINSFILE_PATH}
{{- end }}
{{- end }}

{{- if .Values.externalServices.projectsInfoService.enabled }}
  projects-info-service:
    base-url: ${PROJECTS_INFO_SERVICE_BASE_URL:http://localhost:8081}
{{- end }}
{{- end -}}
