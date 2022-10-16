{% if include.definition.instance_methods.size > 0 %}
## Instance Methods

{% for instance_method in include.definition.instance_methods %}
{% include templates/reference/method.md name=instance_method.name path=instance_method.path type="instance" %}
{% endfor %}
{% endif %}
