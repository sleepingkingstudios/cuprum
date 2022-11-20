---
breadcrumbs:
  - name: Documentation
    path: '../../../'
  - name: Versions
    path: '../../'
  - name: '1.0'
    path: '../'
version: '1.0'
---

{% assign root_namespace = site.namespaces | where: "version", page.version | first %}

# Cuprum Reference

{% include reference/namespace.md label=false namespace=root_namespace %}

{% include breadcrumbs.md %}
