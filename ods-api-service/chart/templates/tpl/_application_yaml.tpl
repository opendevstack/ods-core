{{/* Template for generating application.yaml dynamically from values */}}
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
  security:
    oauth2:
      resourceserver:
        jwt:
          jwk-set-uri: ${OAUTH2_JWK_SET_URI:}
          issuer-uri: ${OAUTH2_ISSUER:}
          audiences:
            - ${OAUTH2_AUDIENCE:}
  datasource:
    url: ${ODS_API_SERVICE_DB_DATASOURCE_URL}
    username: ${ODS_API_SERVICE_DB_USER:opendevstack}
    password: ${ODS_API_SERVICE_DB_PASSWORD:opendevstack}
    driver-class-name: org.postgresql.Driver
    hikari:
      # Pool sizing — tune per environment
      maximum-pool-size: ${HIKARI_POOL_MAX_SIZE:10}
      minimum-idle: ${HIKARI_MIN_IDLE:2}
      connection-timeout: ${HIKARI_CONNECTION_TIMEOUT:30000}
      idle-timeout: ${HIKARI_IDLE_TIMEOUT:600000}
      max-lifetime: ${HIKARI_MAX_LIFETIME:1800000}
  jpa:
    hibernate:
      ddl-auto: ${JPA_HIBERNATE_DDL_AUTO:validate}
    properties:
      hibernate:
        generate_statistics: ${JPA_HIBERNATE_GENERATE_STATISTICS:false}
    open-in-view: ${JPA_OPEN_IN_VIEW:false}
    show-sql: ${JPA_SHOW_SQL:false}

management: {{toYaml .Values.config.management | nindent 2 }}

# App configuration
{{- if .Values.config.app }}
app: {{ toYaml .Values.config.app | nindent 2 }}
{{- end }}

{{- if .Values.config.otel }}
otel: {{ toYaml .Values.config.otel | nindent 2 }}
{{- end }}

automation:
  platform:
{{- if .Values.externalServices.aap.enabled }}
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
      enabled: true
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

# API Configuration
apis:
  project-users:
    enabled: {{ .Values.apis.projectUsers.enabled | default false }}
    ansible-workflow-name: ${API_PROJECT_USERS_WORKFLOW_NAME:}
    token:
      secret: ${API_PROJECT_USERS_TOKEN_SECRET:}
      expiration-hours: ${API_PROJECT_USERS_TOKEN_EXPIRATION_HOURS:}
  projects:
    enabled: {{ .Values.apis.projects.enabled | default false }}
    ansible-workflow-name: ${API_PROJECTS_MINIEDP_PROVISION_WORKFLOW_NAME:}
    locations: ${API_PROJECTS_LOCATIONS:}


# External Service Configuration
externalservices:
  openshift:
{{- if gt (len .Values.externalServices.openshift.instances) 0 }}
    instances:
{{- range $name, $instance := .Values.externalServices.openshift.instances }}
      {{ $name }}:
        api-url: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_API_URL:https://api.dev.ocp.example.com:6443}
        token: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_TOKEN}
        namespace: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_NAMESPACE}
        connection-timeout: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT:30000}
        read-timeout: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT:30000}
        trust-all-certificates: ${OPENSHIFT_{{ $name | upper | replace "-" "_" }}_TRUST_ALL:false}
{{- end }}
{{- else }}
    instances: {}
{{- end }}

  bitbucket:
{{- if gt (len .Values.externalServices.bitbucket.instances) 0 }}
    instances:
{{- range $name, $instance := .Values.externalServices.bitbucket.instances }}
      {{ $name }}:
        base-url: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_BASE_REST_URL}
{{- if $instance.bearerToken }}
        bearer-token: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_BEARER_TOKEN}
{{- else }}
        username: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_USERNAME:}
        password: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_PASSWORD:}
{{- end }}
        connection-timeout: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT:30000}
        read-timeout: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT:30000}
        trust-all-certificates: ${BITBUCKET_{{ $name | upper | replace "-" "_" }}_TRUST_ALL:false}
{{- end }}
{{- else }}
    instances: {}
{{- end }}

  webhook-proxy:
{{- if gt (len .Values.externalServices.webhookProxy.clusters) 0 }}
    clusters:
{{- range $name, $cluster := .Values.externalServices.webhookProxy.clusters }}
      {{ $name }}:
        cluster-base: ${WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_CLUSTER_BASE}
        connection-timeout: ${WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT:30000}
        read-timeout: ${WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT:30000}
        trust-all-certificates: ${WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_TRUST_ALL:false}
        default-jenkinsfile-path: ${WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_JENKINSFILE_PATH:Jenkinsfile}
{{- end }}
{{- else }}
    clusters: {}
{{- end }}

{{- if .Values.externalServices.projectsInfoService.enabled }}
  projects-info-service:
    base-url: ${PROJECTS_INFO_SERVICE_BASE_URL:http://localhost:8081}
{{- end }}

  jira:
{{- if gt (len .Values.externalServices.jira.instances) 0 }}
    default-instance: ${JIRA_DEFAULT_INSTANCE:{{ .Values.externalServices.jira.defaultInstance }}}
    instances:
{{- range $name, $instance := .Values.externalServices.jira.instances }}
      {{ $name }}:
        base-url: ${JIRA_{{ $name | upper | replace "-" "_" }}_BASE_URL}
{{- if $instance.bearerToken }}
        bearer-token: ${JIRA_{{ $name | upper | replace "-" "_" }}_BEARER_TOKEN:}
{{- else }}
        username: ${JIRA_{{ $name | upper | replace "-" "_" }}_USERNAME:}
        password: ${JIRA_{{ $name | upper | replace "-" "_" }}_PASSWORD:}
{{- end }}
        connection-timeout: ${JIRA_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT:30000}
        read-timeout: ${JIRA_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT:30000}
        trust-all-certificates: ${JIRA_{{ $name | upper | replace "-" "_" }}_TRUST_ALL:false}
{{- end }}
{{- else }}
    instances: {}
{{- end }}

services:
  project:
    ldap:
      group:
        pattern: "${SERVICE_PROJECT_LDAP_GROUP_PATTERN}"

{{- end -}}
