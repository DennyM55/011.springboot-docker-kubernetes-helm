{{- define "springboot-chart.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "springboot-chart.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
