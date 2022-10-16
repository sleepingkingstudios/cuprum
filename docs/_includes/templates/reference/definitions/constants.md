{% if include.definition.constants.size > 0 %}
## Constants
{% endif %}

{% for constant in include.definition.constants %}
{% include templates/reference/constant.md constant=constant %}
{% endfor %}
