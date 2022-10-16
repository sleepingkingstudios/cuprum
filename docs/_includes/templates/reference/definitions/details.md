{% if include.definition.extended_modules.size > 0 %}
Extended Modules
: {% for extended_module in include.definition.extended_modules -%}
  {% include templates/reference/reference_link.md label=extended_module.name path=extended_module.path -%}
  {% unless forloop.last %}, {% endunless %}
  {%- endfor %}
{% endif %}

{% if include.definition.included_modules.size > 0 %}
Included Modules
: {% for included_module in include.definition.included_modules -%}
  {% include templates/reference/reference_link.md label=included_module.name path=included_module.path -%}
  {% unless forloop.last %}, {% endunless %}
  {%- endfor %}
{% endif %}

{% if include.definition.files.size > 0 %}
Defined In
: {{ include.definition.files | first }}
{% endif %}
