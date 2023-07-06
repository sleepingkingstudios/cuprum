# Cuprum Docs

To generate the reference documentation, start a REPL in the `/docs` directory and run:

```ruby
require 'sleeping_king_studios/yard'

Dir.chdir '..' # Set the working directory to the root Cuprum directory.

SleepingKingStudios::Yard::Commands::Generate
  .new(
    docs_path: './docs',
    force: true,
  )
  .call(file_path: 'lib')
```

## Generating Version Documentation

To generate the docs for a specific version, specify `version: "X.Y"` in `.new`.

In addition to the reference documentation, the following files must be copied into the new `versions/X.Y` directory:

- All top-level `.md` files except for `README.md`.
- All scoped (non-`assets`, non-`reference`, non-`_`-prefixed) `.md` files, such as those in `/commands`.

Finally, the breadcrumbs for the copied files must be updated to reference the version directory.
