{% if include.definition.instance_methods.size > 0 %}
## Instance Methods

{% for instance_method in include.definition.instance_methods %}
{% include templates/reference/method.md method=instance_method type="instance" %}
{% endfor %}
{% endif %}
