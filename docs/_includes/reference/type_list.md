'Type List ({{ include.types.size }}): {% for type in include.types %}"{% include reference/type.md type=type -%}"{%- unless forloop.last %}, {% endunless -%}{% endfor %}'
