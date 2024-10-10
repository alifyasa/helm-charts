{{- define "uniqueString" -}}
    {{ randAlpha 8 | lower }}
{{- end -}}