{% if include.method.params %}
#### Parameters
{: #{{ include.heading_id }}--parameters }
<ul>
{% for param in include.method.params -%}
<li><strong>{{ param.name }}</strong> ({%- include reference/type_list.md types=param.type -%}){% if param.description.size > 0 %} — {{ param.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endif %}

{% if include.method.options.size > 0 %}
{% for options in include.method.options %}
#### Options Hash ({{ options.name }})
{: #{{ include.heading_id }}--options-{{ options.name }} }
<ul>
{% for option in options.opts -%}
<li><strong>{{ option.name -}}</strong> ({%- include reference/type_list.md types=option.type -%}){% if option.description.size > 0 %} — {{ option.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endfor %}
{% endif %}
