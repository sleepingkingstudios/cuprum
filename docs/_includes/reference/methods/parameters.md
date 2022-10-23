{% if include.method.params %}
#### Parameters
{: #{{ include.heading_id }}--parameters }
{% for param in include.method.params -%}
{% capture type_list %}{%- include reference/type_list.md types=param.type -%}{% endcapture %}
- **{{ param.name -}}** ({{ type_list | strip }}){% if param.description %} — {{ param.description }}{% endif %}
{%- endfor %}
{% endif %}

{% if include.method.options.size > 0 %}
{% for options in include.method.options %}
#### Options Hash ({{ options.name }})
{: #{{ include.heading_id }}--options-{{ options.name }} }
{% for option in options.opts -%}
{% capture type_list %}{%- include reference/type_list.md types=option.type -%}{% endcapture %}
- **{{ option.name -}}** ({{ type_list | strip }}){% if option.description %} — {{ option.description }}{% endif %}
{%- endfor %}
{% endfor %}
{% endif %}
