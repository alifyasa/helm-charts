{{- define "uniqueString" -}}
{{- if not .Values.randomSuffix }}
    {{- $_ := set .Values "randomSuffix" (randAlpha 8 | lower) -}}
{{- end -}}
{{ .Values.randomSuffix }}
{{- end -}}