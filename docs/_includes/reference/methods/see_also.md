{% if include.method.metadata.see.size > 0 %}
{% if include.overload %}
###### See Also
{: #{{ include.heading_id }}--see-also }
{% else %}
#### See Also
{: #{{ include.heading_id }}--see-also }
{% endif %}
{% for see in include.method.metadata.see %}
- {% include reference/reference_link.md label=see.text path=see.path -%}
{% endfor %}
{% endif %}
