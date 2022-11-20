---
breadcrumbs:
  - name: Documentation
    path: '../../'
  - name: Versions
    path: '../'
---

# Cuprum

Cuprum implements the Command pattern for Ruby.

## Documentation

This is the documentation for Version 1.0 of Cuprum.

- For the current development build, see [Documentation]({{site.baseurl}}/).
- For other releases, see the [Versions]({{site.baseurl}}/versions) page.

## Reference

Cuprum defines the following core components:

- **[Commands](./commands)**
  <br>
  A functional object that responds to `#call` and returns a `Cuprum::Result`.
- **[Results](./results)**
  <br>
  An immutable data object representing the result of a called `Cuprum::Command`. Each `Result` has a `#status` (either `:success` or `:failure`), and may have a `#value`, an `#error`, or both.
- **[Errors](./errors)**
  <br>
  An object representing the failure state of a command.
- **[Factories](./factories)**
  <br>
  Provides a DSL to build commands with shared configuration or context.
- **[Matchers](./matchers)**
  <br>
  Define handling for results based on `#status`, `#error`, and `#value`.

For a full list of defined classes and objects, see [Reference](./reference).

{% include breadcrumbs.md %}
