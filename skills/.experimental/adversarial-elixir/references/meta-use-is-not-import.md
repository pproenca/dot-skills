---
title: Use import/alias for functions; reserve `use` for real code injection
tags: meta, use, import, coupling
---

## Use import/alias for functions; reserve `use` for real code injection

Writing `use Helpers` when `Helpers.__using__/1` merely `import`s itself dresses up a plain import as metaprogramming. `use M` invokes `M.__using__/1` and injects whatever code that macro returns into the caller — an opaque coupling where the reader cannot see what was added without opening the other module. When all you want is to call functions, `import`/`alias` says exactly that and injects nothing hidden. Reserve `use` for modules that genuinely must inject behaviour: defining callbacks, registering the module, generating boilerplate you cannot express by calling functions.

**Incorrect (`use` hides a mere import):**

```elixir
defmodule Report do
  use MyApp.Helpers   # __using__ just does `import MyApp.Helpers`
end
```

**Correct (say what you mean):**

```elixir
defmodule Report do
  import MyApp.Helpers, only: [format_currency: 1]
end
```

Reference: [Elixir — Meta-programming anti-patterns: "`use` instead of `import`"](https://hexdocs.pm/elixir/macro-anti-patterns.html)
