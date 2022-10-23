{% if include.definition.constructor %}
## Constructor
{% capture path %}{{ include.definition.data_path }}/i-initialize{% endcapture %}
{% include reference/method.md name="initialize" path=path type="instance" %}
{% endif %}
