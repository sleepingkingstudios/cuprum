{% if page.version == 'dev' or page.version == null %}
This is the documentation for the [current development build]({{site.project_metadata.repository_url}}) of {{site.project_metadata.name}}.

{% assign latest_version = site.versions | sort: "sortable" | map: "version" | last %}
{% if latest_version %}
- For the most recent release, see [Version {{latest_version}}]({{site.baseurl}}/versions/{{latest_version}}).
{% endif -%}
{% else -%}
This is the documentation for Version {{page.version}} of {{site.project_metadata.name}}.

- For the current development build, see [Documentation]({{site.baseurl}}/).
{% endif -%}
- For previous releases, see the [Versions]({{site.baseurl}}/versions) page.
