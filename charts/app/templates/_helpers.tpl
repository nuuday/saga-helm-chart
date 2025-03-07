{{/*
Expand the name of the service.
*/}}
{{- define "nmp-chart.serviceName" -}}
{{- default .Values.serviceName .Values.serviceNameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the deployment name of the chart.
*/}}
{{- define "nmp-chart.deploymentName" -}}
{{- $name := "" }}
{{- if index .Values "deployment-name" }}
{{- $name = index .Values "deployment-name" }}
{{- else if .Values.deploymentNameOverride }}
{{- $name = .Values.deploymentNameOverride }}
{{- else }}
{{- $name = .Release.Name }}
{{- end }}
{{- if and .Values.prNumber (ne .Values.prNumber "") }}
{{- printf "%s-pr-%s" $name .Values.prNumber | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nmp-chart.hostName" -}}
{{- if .Values.hostNameOverride }}
{{- .Values.hostNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $serviceName := default (include "nmp-chart.serviceName" .) }}
{{- printf "%s-%s" $serviceName .Values.environmentName | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nmp-chart.fullName" -}}
{{- if .Values.fullNameOverride }}
{{- .Values.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $deploymentName := default (include "nmp-chart.deploymentName" .) }}
{{- printf "%s-%s" $deploymentName .Values.environmentName | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nmp-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create service account name.
*/}}
{{- define "nmp-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ include "nmp-chart.fullName" . }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "nmp-chart.labels" -}}
helm.sh/chart: {{ include "nmp-chart.chart" . }}
{{ include "nmp-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nmp-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nmp-chart.deploymentName" . }}
app.kubernetes.io/instance: {{ include "nmp-chart.deploymentName" . }}
{{- if .Values.aadpodidbinding }}
aadpodidbinding: {{ .Values.aadpodidbinding }}
{{- end }}
{{- end }}

{{/*applicationService and spoc annotations
*/}}
{{- define "nmp-chart.annotations" -}}
spoc: "Niclas Schumacher nsch@nuuday.dk"
application_service: {{ printf "saga-%s" .Values.environmentName | trunc 63 | trimSuffix "-" }}
{{- end }}
