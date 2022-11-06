{% if include.definition.constants.size > 0 %}
## Constants
{% endif %}

{% for constant in include.definition.constants %}
{% include reference/constant.md constant=constant inherited=constant.inherited %}
{% endfor %}
