{% assign method = site.methods | where: "data_path", include.path | where: "version", page.version | first %}

{% capture char %}{% if include.type == "class" %}.{% else %}#{% endif %}{% endcapture %}
{% capture prefix %}{{ include.type }}-method{% endcapture %}
{% capture heading_id %}{{ prefix }}-{{ method.slug | replace: "=", "--equals" }}{% endcapture %}

<h3><code>{{ char }}{{ method.signature }} => {% include reference/methods/return_types.md method=method -%}</code></h3>
{: #{{ heading_id }} }

> @todo
