{% if include.definition.class_methods.size > 0 %}
## Class Methods

{% for class_method in include.definition.class_methods %}
{% include templates/reference/method.md method=class_method type="class" %}
{% endfor %}
{% endif %}
