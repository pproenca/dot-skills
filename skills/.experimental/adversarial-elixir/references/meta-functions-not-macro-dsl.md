---
title: Express configuration as data and functions, not a macro DSL
tags: meta, macros, dsl, data
---

## Express configuration as data and functions, not a macro DSL

A home-grown macro DSL — `defrule`, `field ...`, `validates ...` — is an entire metaprogramming layer built to express what is really a list of rules. Collapse it: macros run at compile time, are hard to debug (you must reason about the expanded code), and cannot be composed, inspected, or passed as values. Most such "DSLs" are just a data structure plus a function that interprets it — and data can be built at runtime, tested directly, and stored. Deleting the DSL removes a `__using__`, a pile of `defmacro`s, and the compile-time coupling they carry, replacing all of it with a plain list and one interpreter function. Reach for a macro only when you must generate code that genuinely cannot be expressed as runtime data, and keep it thin.

**Evidence of violation:** a `defmacro` (or `__using__`-injected DSL) defined in the target whose expansion only encodes configuration or rules — to FAIL, the reviewer must sketch the equivalent plain form (the data structure plus the interpreter function that replaces the macro layer); if no such equivalent exists, the verdict is PASS. PASS: configuration expressed as data (module attributes, structs, keyword lists) interpreted by functions; any remaining macros generate code that runtime data cannot express (new function heads from external input, compile-time derivation). N/A: no macros defined in the target — *using* third-party DSLs (Ecto schemas, Phoenix router, Absinthe) is not a violation; this rule judges DSLs the target itself defines.

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
