{% if include.definition.class_methods.size > 0 %}
## Class Methods
{% endif %}

{% for class_method in include.definition.class_methods %}
{% include reference/method.md name=class_method.name path=class_method.path type="class" %}
{% endfor %}
