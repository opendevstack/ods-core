{{/* External services domain: third-party and platform integrations */}}
{{- define "chart.externalServicesConfigData" }}
{{- if .Values.externalServices.aap.enabled }}
## Ansible Automation Platform configuration
ANSIBLE_BASE_URL: {{ .Values.externalServices.aap.baseUrl | quote }}
ANSIBLE_TIMEOUT: {{ .Values.externalServices.aap.timeout | quote }}
ANSIBLE_SSL_VERIFY: {{ .Values.externalServices.aap.ssl.verifyCertificates | quote }}
{{- if .Values.externalServices.aap.ssl.trustStorePath }}
ANSIBLE_SSL_TRUSTSTORE_PATH: {{ .Values.externalServices.aap.ssl.trustStorePath | quote }}
{{- end }}
{{- if .Values.externalServices.aap.ssl.trustStoreType }}
ANSIBLE_SSL_TRUSTSTORE_TYPE: {{ .Values.externalServices.aap.ssl.trustStoreType | quote }}
{{- end }}
{{- end }}
{{- if .Values.externalServices.uipath.enabled }}
## UiPath configuration
UIPATH_HOST: {{ .Values.externalServices.uipath.host | quote }}
UIPATH_TENANCY_NAME: {{ .Values.externalServices.uipath.tenancyName | quote }}
UIPATH_ORGANIZATION_UNIT_ID: {{ .Values.externalServices.uipath.organizationUnitId | quote }}
UIPATH_TIMEOUT: {{ .Values.externalServices.uipath.timeout | quote }}
UIPATH_SSL_VERIFY: {{ .Values.externalServices.uipath.ssl.verifyCertificates | quote }}
{{- if .Values.externalServices.uipath.ssl.trustStorePath }}
UIPATH_SSL_TRUSTSTORE_PATH: {{ .Values.externalServices.uipath.ssl.trustStorePath | quote }}
{{- end }}
{{- if .Values.externalServices.uipath.ssl.trustStoreType }}
UIPATH_SSL_TRUSTSTORE_TYPE: {{ .Values.externalServices.uipath.ssl.trustStoreType | quote }}
{{- end }}
{{- end }}
{{- if .Values.externalServices.projectsInfoService.enabled }}
## Projects Info Service configuration
PROJECTS_INFO_SERVICE_BASE_URL: {{ .Values.externalServices.projectsInfoService.baseUrl | quote }}
{{- end }}
{{- if gt (len .Values.externalServices.openshift.instances) 0 }}
## OpenShift configuration
{{- range $name, $instance := .Values.externalServices.openshift.instances }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_API_URL: {{ $instance.apiUrl | quote }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_NAMESPACE: {{ $instance.namespace | quote }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT: {{ $instance.connectionTimeout | quote }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT: {{ $instance.readTimeout | quote }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_TRUST_ALL: {{ default false $instance.trustAllCertificates | quote }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.bitbucket.instances) 0 }}
## Bitbucket configuration
{{- range $name, $instance := .Values.externalServices.bitbucket.instances }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_BASE_REST_URL: {{ $instance.baseUrl | quote }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT: {{ $instance.connectionTimeout | quote }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT: {{ $instance.readTimeout | quote }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_TRUST_ALL: {{ default false $instance.trustAllCertificates | quote }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.jira.instances) 0 }}
## Jira configuration
JIRA_DEFAULT_INSTANCE: {{ .Values.externalServices.jira.defaultInstance | quote }}
{{- range $name, $instance := .Values.externalServices.jira.instances }}
JIRA_{{ $name | upper | replace "-" "_" }}_BASE_URL: {{ $instance.baseUrl | quote }}
JIRA_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT: {{ $instance.connectionTimeout | quote }}
JIRA_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT: {{ $instance.readTimeout | quote }}
JIRA_{{ $name | upper | replace "-" "_" }}_TRUST_ALL: {{ default false $instance.trustAllCertificates | quote }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.webhookProxy.clusters) 0 }}
## Webhook proxy configuration
{{- range $name, $cluster := .Values.externalServices.webhookProxy.clusters }}
WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_CLUSTER_BASE: {{ $cluster.clusterBase | quote }}
WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_CONNECTION_TIMEOUT: {{ $cluster.connectionTimeout | quote }}
WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_READ_TIMEOUT: {{ $cluster.readTimeout | quote }}
WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_TRUST_ALL: {{ default false $cluster.trustAllCertificates | quote }}
WEBHOOK_PROXY_{{ $name | upper | replace "-" "_" }}_JENKINSFILE_PATH: {{ $cluster.defaultJenkinsfilePath | quote }}
{{- end }}
{{- end }}

## Mkt configuration
MARKETPLACE_DEFAULT_INSTANCE: {{ .Values.externalServices.marketplace.defaultInstance | quote }}
{{- range $name, $instance := .Values.externalServices.marketplace.instances }}
MARKETPLACE_{{ $name | upper | replace "-" "_" }}_PROJECT_COMPONENT_BASE_URL: {{ $instance.projectComponentsBaseUrl | quote }}
MARKETPLACE_{{ $name | upper | replace "-" "_" }}_PROVISIONER_ACTIONS_BASE_URL: {{ $instance.provisionerActionsBaseUrl | quote }}
MARKETPLACE_{{ $name | upper | replace "-" "_" }}_OBO_SCOPE: {{ $instance.oboScope | quote }}
{{- end }}
{{- end }}

{{- define "chart.externalServicesSecretData" }}
{{- if .Values.externalServices.aap.enabled }}
## Ansible Automation Platform secrets
ANSIBLE_USERNAME: {{ .Values.externalServices.aap.username | b64enc | quote }}
ANSIBLE_PASSWORD: {{ .Values.externalServices.aap.password | b64enc | quote }}
{{- if .Values.externalServices.aap.ssl.trustStorePassword }}
ANSIBLE_SSL_TRUSTSTORE_PASSWORD: {{ .Values.externalServices.aap.ssl.trustStorePassword | b64enc | quote }}
{{- end }}
{{- end }}
{{- if .Values.externalServices.uipath.enabled }}
## UiPath secrets
UIPATH_CLIENT_ID: {{ .Values.externalServices.uipath.clientId | b64enc | quote }}
UIPATH_CLIENT_SECRET: {{ .Values.externalServices.uipath.clientSecret | b64enc | quote }}
{{- if .Values.externalServices.uipath.ssl.trustStorePassword }}
UIPATH_SSL_TRUSTSTORE_PASSWORD: {{ .Values.externalServices.uipath.ssl.trustStorePassword | b64enc | quote }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.openshift.instances) 0 }}
## OpenShift secrets
{{- range $name, $instance := .Values.externalServices.openshift.instances }}
OPENSHIFT_{{ $name | upper | replace "-" "_" }}_TOKEN: {{ $instance.token | b64enc | quote }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.bitbucket.instances) 0 }}
## Bitbucket secrets
{{- range $name, $instance := .Values.externalServices.bitbucket.instances }}
{{- if $instance.bearerToken }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_BEARER_TOKEN: {{ $instance.bearerToken | b64enc | quote }}
{{- end }}
{{- if $instance.username }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_USERNAME: {{ $instance.username | b64enc | quote }}
{{- end }}
{{- if $instance.password }}
BITBUCKET_{{ $name | upper | replace "-" "_" }}_PASSWORD: {{ $instance.password | b64enc | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.jira.instances) 0 }}
## Jira secrets
{{- range $name, $instance := .Values.externalServices.jira.instances }}
{{- if $instance.bearerToken }}
JIRA_{{ $name | upper | replace "-" "_" }}_BEARER_TOKEN: {{ $instance.bearerToken | b64enc | quote }}
{{- end }}
{{- if $instance.username }}
JIRA_{{ $name | upper | replace "-" "_" }}_USERNAME: {{ $instance.username | b64enc | quote }}
{{- end }}
{{- if $instance.password }}
JIRA_{{ $name | upper | replace "-" "_" }}_PASSWORD: {{ $instance.password | b64enc | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if gt (len .Values.externalServices.jenkins.environments) 0 }}
## Jenkins secrets
{{- range $index, $env := .Values.externalServices.jenkins.environments }}
JENKINS_{{ $env.name | upper | replace "-" "_" }}_API_TOKEN: {{ $env.apiToken | b64enc | quote }}
{{- end }}
{{- end }}
{{- end }}
