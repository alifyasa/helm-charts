{{- define "uniqueString" -}}
{{- if .Values.fullnameOverride -}}
    {{ .Values.fullnameOverride }}
{{- else -}}
    {{ randAlpha 8 | lower }}
{{- end -}}
{{- end -}}