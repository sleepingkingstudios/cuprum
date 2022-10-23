{% if include.method.returns.size > 0 %}
#### Returns
{: #{{ include.heading_id }}--returns }
{% for return in include.method.returns -%}
{% capture type_list %}{%- include reference/type_list.md types=return.type -%}{% endcapture %}
- ({{ type_list | strip }}){% if return.description %} — {{ return.description }}{% endif %}
{%- endfor %}
{% endif %}
