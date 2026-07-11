---
title: Use import/alias for functions; reserve `use` for real code injection
tags: meta, use, import, coupling
---

## Use import/alias for functions; reserve `use` for real code injection

Writing `use Helpers` when `Helpers.__using__/1` merely `import`s itself dresses up a plain import as metaprogramming. `use M` invokes `M.__using__/1` and injects whatever code that macro returns into the caller — an opaque coupling where the reader cannot see what was added without opening the other module. When all you want is to call functions, `import`/`alias` says exactly that and injects nothing hidden. Reserve `use` for modules that genuinely must inject behaviour: defining callbacks, registering the module, generating boilerplate you cannot express by calling functions.

**Evidence of violation:** a `__using__/1` macro defined in the target whose `quote` block contains only `import`, `alias`, and/or `require` — no `def`/`defmacro`, no `@behaviour`/attribute registration, no generated code (this requires opening the used module, possibly beyond the diff). Call sites writing `use ThatModule` inherit the violation; cite the `__using__` body. PASS: callers use `import`/`alias` directly, and every `__using__` in the target injects something an import cannot (callbacks, attributes, generated functions). N/A: the target defines no `__using__` and adds no `use` of first-party modules — `use GenServer`, `use Phoenix.LiveView`, and other third-party `use` sites are out of scope.

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
