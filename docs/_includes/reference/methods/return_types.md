{%- if include.method.constructor -%}
{{ type.name }}
{%- elsif include.method.returns.size > 0 -%}
{% for returns in include.method.returns %}
{%- include reference/type_list.md types=returns.type -%}{%- unless forloop.last -%}, {% endunless -%}
{% endfor %}
{%- else -%}
Object
{%- endif -%}
