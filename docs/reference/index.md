---
breadcrumbs:
  - name: Documentation
    path: '../'
---

{% assign root_namespace = site.namespaces | where: "version", "*" | first %}

# Cuprum Reference

{% include templates/reference/namespace.md label=false namespace=root_namespace %}

{% include breadcrumbs.md %}
