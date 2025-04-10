{{/*
Expand the name of the chart.
*/}}
{{- define "fastapi-app.name" -}}
{{- default .Chart.Name .Values.fastapi.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fastapi-app.fullname" -}}
{{- if .Values.fastapi.fullnameOverride }}
{{- .Values.fastapi.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.fastapi.nameOverride }}
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
{{- define "fastapi-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fastapi-app.labels" -}}
helm.sh/chart: {{ include "fastapi-app.chart" . }}
{{ include "fastapi-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fastapi-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fastapi-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "fastapi-app.serviceAccountName" -}}
{{- if .Values.fastapi.serviceAccount.create }}
{{- default (include "fastapi-app.fullname" .) .Values.fastapi.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.fastapi.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* No longer needed - using custom PostgreSQL deployment */}}