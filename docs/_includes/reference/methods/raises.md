{% if include.method.raises.size > 0 %}
#### Raises
{: #{{ include.heading_id }}--raises }
<ul>
{% for raised in include.method.raises -%}
<li>({%- include reference/type_list.md types=raised.type -%}){% if raised.description.size > 0 %} — {{ raised.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endif %}
