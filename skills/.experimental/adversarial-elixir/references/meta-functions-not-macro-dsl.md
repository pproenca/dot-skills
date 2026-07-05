---
title: Express configuration as data and functions, not a macro DSL
tags: meta, macros, dsl, data
---

## Express configuration as data and functions, not a macro DSL

A home-grown macro DSL — `defrule`, `field ...`, `validates ...` — is an entire metaprogramming layer built to express what is really a list of rules. Collapse it: macros run at compile time, are hard to debug (you must reason about the expanded code), and cannot be composed, inspected, or passed as values. Most such "DSLs" are just a data structure plus a function that interprets it — and data can be built at runtime, tested directly, and stored. Deleting the DSL removes a `__using__`, a pile of `defmacro`s, and the compile-time coupling they carry, replacing all of it with a plain list and one interpreter function. Reach for a macro only when you must generate code that genuinely cannot be expressed as runtime data, and keep it thin.

**Incorrect (a macro DSL for what is plain data):**

```elixir
validate_user do
  field :email, required: true
  field :age, min: 18
end
```

**Correct (data + a function interpreting it):**

```elixir
@rules [
  {:email, required: true},
  {:age, min: 18}
]

def validate(user), do: MyApp.Validator.run(user, @rules)
```

Reference: [Elixir — Meta-programming anti-patterns: "Unnecessary macros"](https://hexdocs.pm/elixir/macro-anti-patterns.html)
