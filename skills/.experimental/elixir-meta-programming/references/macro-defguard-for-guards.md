---
title: Use defguard for constructs that must work inside a guard
tags: macro, defguard, guards, is_
---

## Use defguard for constructs that must work inside a guard

When you want a named test usable in a guard — `when is_weekday(day)` — a plain function won't compile there (guards only allow a fixed set of guard-safe operators), and a regular `defmacro` that returns a `quote` works but silently allows non-guard code to leak in, producing confusing errors at each call site. `defguard`/`defguardp` exists for exactly this: it defines the expression once, enforces at *definition* time that the body is guard-safe, and expands cleanly into both guard and normal call positions. Reaching for a bare macro here is the wrong default because it drops that guard-safety check.

```elixir
defmodule Calendar.Guards do
  defguard is_weekday(day) when day in 1..5
  defguard is_hour(h) when is_integer(h) and h >= 0 and h <= 23
end

defmodule Scheduler do
  import Calendar.Guards

  def slot(day, hour) when is_weekday(day) and is_hour(hour), do: {:ok, {day, hour}}
  def slot(_, _), do: :error
end
```

Reference: [Elixir — `Kernel.defguard/1`](https://elixir.hexdocs.pm/Kernel.html#defguard/1)
