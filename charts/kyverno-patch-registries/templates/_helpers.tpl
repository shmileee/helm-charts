{{- define "image.matchSelector" -}}
match:
  resources:
    kinds:
      - Pod
    namespaceSelector:
      matchLabels:
        {{ $.Values.common.namespaceSelectorLabel | default "pull-through-enabled" }}: "true"
{{- end }}

{{- define "image.mutation.context" -}}
context:
  - name: ecrRegistryFullname
    variable:
      value: "{{ $.Values.common.ecrRegistryFullname }}"
  - name: upstreamUrlRegexp
    variable:
      value: "{{ $.Values.config.upstreamUrlRegexp }}"
  - name: ecrPrefixName
    variable:
      value: "{{ $.Values.config.ecrPrefixName }}"
  # If no repository is specified, prepend library/
  - name: withDefaultRepository
    variable:
      value: "{{`{{ regex_replace_all('^([^/]+)$', '{{ element.image }}', 'library/$1') }}`}}"
  # Normalize:
  # - if no registry is specified, prepend docker.io
  # - if no tag is specified, append :latest
  - name: imageNormalized
    variable:
      value: "{{`{{ image_normalize(withDefaultRepository) }}`}}"
  # Replace the upstream URL pattern with ECR registry prefix
  - name: finalImage
    variable:
      value: "{{`{{ regex_replace_all('{{ upstreamUrlRegexp }}', imageNormalized, '{{ ecrRegistryFullname }}/{{ ecrPrefixName }}/$1') }}`}}"
{{- end }}
