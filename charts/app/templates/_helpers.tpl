{{/*
Expand the name of the chart.
*/}}
{{- define "nmp-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nmp-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nmp-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

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
app.kubernetes.io/name: {{ include "nmp-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
aadpodidbinding: {{ .Values.aadpodidbinding }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nmp-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nmp-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service monitor to use
*/}}
{{- define "nmp-chart.serviceMonitorName" -}}
{{- if .Values.serviceMonitor.create }}
{{- default (include "nmp-chart.fullname" .) .Values.serviceMonitor.name }}
{{- else }}
{{- default "default" .Values.serviceMonitor.name }}
{{- end }}
{{- end }}