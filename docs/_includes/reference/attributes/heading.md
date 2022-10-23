{% capture char %}{% if include.type == "class" %}.{% else %}#{% endif %}{% endcapture %}
{% capture prefix %}{{ include.type }}-attribute{% endcapture %}
{% capture access %}{% if include.attribute.read and include.attribute.write %}{% elsif include.attribute.read %} <small>(readonly)</small>{% else %} <small>(writeonly)</small>{% endif %}{% endcapture %}

<h3><code>{{ char }}{{ include.method.signature }} => {% include reference/methods/return_types.md method=include.method %}{{ access }}</code></h3>
{: #{{ include.heading_id }} }
