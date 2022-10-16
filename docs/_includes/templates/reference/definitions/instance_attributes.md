{% if include.definition.instance_attributes.size > 0 %}
## Instance Attributes

{% for instance_attribute in include.definition.instance_attributes %}
{% include templates/reference/attribute.md attribute=instance_attribute type="instance" %}
{% endfor %}
{% endif %}
