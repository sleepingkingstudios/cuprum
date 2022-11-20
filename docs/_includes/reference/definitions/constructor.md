{% if include.definition.constructor %}
{% capture path %}{% for instance_method in include.definition.instance_methods %}{% if instance_method.constructor %}{{ instance_method.path }}{% endif %}{% endfor %}{% endcapture %}
## Constructor
{% include reference/method.md name="initialize" path=path type="instance" %}
{% endif %}
