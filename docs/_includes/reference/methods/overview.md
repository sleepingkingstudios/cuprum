{% if include.method.metadata.todos.size > 0 %}
{% for todo in include.method.metadata.todos %}
> **Todo:** {{ todo }}
{% endfor %}
{% endif %}

{% if include.method.metadata.notes.size > 0 %}
{% for note in include.method.metadata.notes %}
> *Note:* {{ note }}
{% endfor %}
{% endif %}

{% if include.method.short_description %}
{{ include.method.short_description }}
{% endif %}

{% if include.method.description %}
{{ include.method.description }}
{% endif %}

{% if include.method.metadata.examples.size > 0 %}
{% if include.overload %}
###### Examples
{: #{{ include.heading_id }}--examples }
{% else %}
#### Examples
{: #{{ include.heading_id }}--examples }
{% endif %}
{% for example in include.method.metadata.examples %}
**{{ example.name }}**

{% highlight ruby %}{{ example.text }}{% endhighlight %}
{% endfor %}
{% endif %}
