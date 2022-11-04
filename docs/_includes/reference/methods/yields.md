{% if include.method.yields.size > 0 %}
#### Yields
{: #{{ include.heading_id }}--yields }
{% for yielded in include.method.yields %}
- {% if yielded.parameters.size > 0 %}({% for parameter in yielded.parameters %}{{ parameter }}{% unless forloop.last %}, {% endunless %}{% endfor %}){% if yielded.description.size > 0 %} — {% endif %}{% endif %}{% if yielded.description.size > 0 %}{{ yielded.description }}{% endif -%}
{% endfor %}
{% endif %}

{% if include.method.yield_params.size > 0 %}
#### Yield Parameters
{: #{{ include.heading_id }}--yield-parameters }
<ul>
{% for param in include.method.yield_params -%}
<li><strong>{{ param.name -}}</strong> ({%- include reference/type_list.md types=param.type -%}){% if param.description.size > 0 %} — {{ param.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endif %}

{% if include.method.yield_returns.size > 0 %}
#### Yield Returns
{: #{{ include.heading_id }}--yield-returns }
<ul>
{% for return in include.method.yield_returns -%}
<li>({%- include reference/type_list.md types=return.type -%}){% if return.description.size > 0 %} — {{ return.description }}{% endif %}</li>
{%- endfor %}
</ul>
{% endif %}
