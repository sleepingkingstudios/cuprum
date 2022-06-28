---
---

# Cuprum

Cuprum implements the Command pattern for Ruby.

## Documentation

This is the documentation for the [current development build](https://github.com/sleepingkingstudios/cuprum) of Cuprum.

- For the most recent release, see [Version 1.0](#).
- For previous releases, see the [Versions]({{site.baseurl}}/versions) page.

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

For a full list of defined classes and objects, see [Reference](./reference).
