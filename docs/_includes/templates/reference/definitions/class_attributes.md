{% if include.definition.class_attributes.size > 0 %}
## Class Attributes

{% for class_attribute in include.definition.class_attributes %}
{% include templates/reference/attribute.md attribute=class_attribute type="class" %}
{% endfor %}
{% endif %}
