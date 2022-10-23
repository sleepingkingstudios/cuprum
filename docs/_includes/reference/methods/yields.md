{% if include.method.yields.size > 0 %}
#### Yields
{: #{{ include.heading_id }}--yields }

{% for yielded in include.method.yields %}
- {% if yielded.parameters.size > 0 %}({% for parameter in yielded.parameters %}{{ parameter }}{% unless forloop.last %}, {% endunless %}{% endfor %}){% if yielded.description %} — {% endif %}{% endif %}{% if yielded.description %}{{ yielded.description }}{% endif %}
{% endfor %}
{% endif %}

{% if include.method.yield_params.size > 0 %}
#### Yield Parameters
{: #{{ include.heading_id }}--yield-parameters }
{% for param in include.method.yield_params -%}
{% capture type_list %}{%- include reference/type_list.md types=param.type -%}{% endcapture %}
- **{{ param.name -}}** ({{ type_list | strip }}){% if param.description %} — {{ param.description }}{% endif %}
{%- endfor %}
{% endif %}

{% if include.method.yield_returns.size > 0 %}
#### Yield Returns
{: #{{ include.heading_id }}--yield-returns }
{% for return in include.method.yield_returns -%}
{% capture type_list %}{%- include reference/type_list.md types=return.type -%}{% endcapture %}
- ({{ type_list | strip }}){% if return.description %} — {{ return.description }}{% endif %}
{%- endfor %}
{% endif %}
