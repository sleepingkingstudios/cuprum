{% if include.inherited %}
{% assign parent_definition = site.classes | where: "data_path", include.method.parent_path | where: "version", page.version | first %}
{% unless parent_definition %}{% assign parent_definition = site.modules | where: "data_path", include.method.parent_path | where: "version", page.version | first %}{% endunless %}
{% if include.type == "class" %}Extended{% else %}Inherited{% endif %} From
: {% if parent_definition %}{% include reference/reference_link.md label=parent_definition.name path=parent_definition.data_path %}{% else %}Object{% endif %}
{% endif %}
