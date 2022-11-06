{% if include.constant.metadata.todos.size > 0 %}
{% for todo in include.constant.metadata.todos %}
> **Todo:** {{ todo }}
{% endfor %}
{% endif %}

{% if include.constant.metadata.notes.size > 0 %}
{% for note in include.constant.metadata.notes %}
> *Note:* {{ note }}
{% endfor %}
{% endif %}

{% if include.constant.short_description %}
{{ include.constant.short_description }}
{% endif %}

{% if include.constant.description %}
{{ include.constant.description }}
{% endif %}

{% if include.constant.metadata.examples.size > 0 %}
#### Examples
{: #{{ include.heading_id }}--examples }
{% for example in include.constant.metadata.examples %}
**{{ example.name }}**

{% highlight ruby %}{{ example.text }}{% endhighlight %}
{% endfor %}
{% endif %}
