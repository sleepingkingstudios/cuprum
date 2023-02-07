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

To generate the docs for a specific version, specify `version: ""` in `.new`.
