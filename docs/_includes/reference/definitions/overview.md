## Overview

{% if include.definition.metadata.todos.size > 0 %}
{% for todo in include.definition.metadata.todos %}
> **Todo:** {{ todo }}
{% endfor %}
{% endif %}

{% if include.definition.metadata.notes.size > 0 %}
{% for note in include.definition.metadata.notes %}
> *Note:* {{ note }}
{% endfor %}
{% endif %}

{% if include.definition.short_description %}
{{ include.definition.short_description }}
{% endif %}

{% if include.definition.description %}
{{ include.definition.description }}
{% endif %}

{% if include.definition.metadata.examples.size > 0 %}
### Examples

{% for example in include.definition.metadata.examples %}
**{{ example.name }}**
{% highlight ruby %}
{{ example.text }}
{% endhighlight %}
{% endfor %}
{% endif %}

{% if include.definition.metadata.see.size > 0 %}
### See Also

{% for see in include.definition.metadata.see %}
- {% include reference/reference_link.md label=see.text path=see.path -%}
{% endfor %}
{% endif %}
