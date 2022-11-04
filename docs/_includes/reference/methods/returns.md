{% if include.method.returns.size > 0 %}
#### Returns
{: #{{ include.heading_id }}--returns }
<ul>
{% for return in include.method.returns -%}
<li>({%- include reference/type_list.md types=return.type -%}){% if return.description.size > 0 %} — {{ return.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endif %}
