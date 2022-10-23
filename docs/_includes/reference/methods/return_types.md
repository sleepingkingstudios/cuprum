{%- if include.method.constructor -%}
{{ type.name }}
{%- elsif include.method.returns.size > 0 -%}
{% for returns in include.method.returns %}
{% capture type_list %}{%- include reference/type_list.md types=returns.type -%}{% endcapture %}
{{ type_list | strip }}{%- unless forloop.last -%}, {% endunless -%}
{% endfor %}
{%- else -%}
Object
{%- endif -%}
