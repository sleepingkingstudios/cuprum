{%- if include.path %}
{%- capture url %}/reference/{{ include.path }}{% endcapture -%}
<a href="{{ url }}">{{ include.label }}</a>
{%- else -%}
{{ include.label -}}
{% endif -%}
