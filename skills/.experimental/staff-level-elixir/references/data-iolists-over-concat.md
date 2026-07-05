---
title: Build large output as iolists, not with repeated `<>`
tags: data, iolist, binaries, performance
---

## Build large output as iolists, not with repeated `<>`

Binaries are immutable, so `acc <> chunk` in a loop copies the entire accumulated binary on every iteration — O(n²) total work and O(n) garbage. The idiomatic BEAM move is to accumulate an **iolist**: a nested, unflattened list of binaries and bytes that you build in O(1) per append by prepending or nesting. Functions like `IO.iodata_to_binary/1` flatten it once at the end, and — crucially — `File.write/2`, `:gen_tcp.send/2`, Plug responses, and most IO accept iodata directly, so you often never flatten at all. Reserve `<>` for joining a handful of known parts, not for accumulating in a reduce or recursion.

**Correct (iolist — O(n), no recopying):**

```elixir
# Build an iolist; each row just nests — no recopying of prior output.
def render_csv(rows) do
  Enum.map(rows, fn %{name: name, total: total} ->
    [name, ",", Integer.to_string(total), "\n"]
  end)
end

# Write the iolist straight to disk — no intermediate giant binary.
File.write!("report.csv", render_csv(rows))
```

**Incorrect (O(n²) — recopies the whole accumulator each row):**

```elixir
Enum.reduce(rows, "", fn %{name: name, total: total}, acc ->
  acc <> name <> "," <> Integer.to_string(total) <> "\n"
end)
```

Reference: [Erlang Efficiency Guide — Constructing binaries / iolists](https://www.erlang.org/doc/system/binaryhandling.html)
