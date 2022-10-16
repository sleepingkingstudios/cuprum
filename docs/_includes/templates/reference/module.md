{% assign definition = site.modules | where: "data_path", page.data_path | where: "version", page.version | first %}

# Module: {{ definition.name }}

{% include templates/reference/definitions/details.md definition=definition %}

{% include templates/reference/definitions/overview.md definition=definition %}

{% include templates/reference/definitions/definitions.md definition=definition %}

{% include templates/reference/definitions/constants.md definition=definition %}

{% include templates/reference/definitions/class_attributes.md definition=definition %}

{% include templates/reference/definitions/class_methods.md definition=definition %}

{% include templates/reference/definitions/instance_attributes.md definition=definition %}

{% include templates/reference/definitions/instance_methods.md definition=definition %}
