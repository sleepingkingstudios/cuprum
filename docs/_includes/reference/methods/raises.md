{% if include.method.raises.size > 0 %}
#### Raises
{: #{{ include.heading_id }}--raises }
{% for raised in include.method.raises -%}
{% capture type_list %}{%- include reference/type_list.md types=raised.type -%}{% endcapture %}
- ({{ type_list | strip }}){% if raised.description %} — {{ raised.description }}{% endif %}
{%- endfor %}
{% endif %}
