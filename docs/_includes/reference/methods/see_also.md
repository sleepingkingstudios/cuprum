{% if include.method.metadata.see.size > 0 %}
#### See Also
{: #{{ include.heading_id }}--see-also }
{% for see in include.method.metadata.see %}
- {% include reference/reference_link.md label=see.text path=see.path -%}
{% endfor %}
{% endif %}
