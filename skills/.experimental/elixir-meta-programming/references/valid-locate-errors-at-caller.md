---
title: Point compile errors at the caller's DSL line
tags: valid, caller, errors, macro-env
---

## Point compile errors at the caller's DSL line

A DSL error is only useful if it names the offending line in the *user's* file. Per-declaration checks (this field's own options are wrong) can raise straight from the macro body — a `raise` during expansion is attributed to the exact call site automatically. But whole-DSL checks — duplicate names, a missing required declaration — need every declaration at once, and those are only reliably assembled in `@before_compile`; reading the accumulating attribute *mid-expansion* doesn't see declarations whose code hasn't executed yet. So capture `__CALLER__.line` (from the `%Macro.Env{}`) alongside each declaration, and when the deferred `@before_compile` check raises, cite that stored line — otherwise the error points at the hook, not the user's source.

```elixir
defmacro field(name, opts) do
  line = __CALLER__.line              # stash where the user wrote this
  quote do
    @fields {unquote(name), unquote(line), unquote(opts)}
  end
end

defmacro __before_compile__(env) do
  fields = env.module |> Module.get_attribute(:fields) |> Enum.reverse()

  case Enum.group_by(fields, &elem(&1, 0)) |> Enum.find(fn {_n, occ} -> length(occ) > 1 end) do
    {name, occ} ->
      {_name, line, _opts} = Enum.at(occ, 1)   # the redefinition's stored line
      raise ArgumentError,
        "#{Path.relative_to_cwd(env.file)}:#{line}: field #{inspect(name)} is already defined"

    nil ->
      quote do: def(__fields__, do: unquote(Enum.map(fields, &elem(&1, 0))))
  end
end
```

Reference: [Elixir — `Macro.Env` (`__CALLER__`)](https://elixir.hexdocs.pm/Macro.Env.html)
