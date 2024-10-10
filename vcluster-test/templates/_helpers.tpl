{{- define "uniqueString" -}}
{{- if .Values.fullnameOverride -}}
    {{ .Values.fullnameOverride }}
{{- else -}}
    {{- printf (randAlpha 8 | lower) -}}
{{- end -}}
{{- end -}}