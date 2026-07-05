---
title: Choose Stream vs Enum by size and composition, not by reflex
tags: data, stream, enum, laziness
---

## Choose Stream vs Enum by size and composition, not by reflex

`Enum` is eager: every step builds a full intermediate list, so `Enum.map |> Enum.filter |> Enum.take` materializes the whole collection twice before taking a few elements. The wrong default in *both* directions is common. Reach for `Stream` when the source is large or unbounded, when you compose several transformations (they fuse into a single pass), or when you can stop early (`Stream.take`, `Enum.find`) and avoid processing the rest. But don't cargo-cult `Stream` onto small in-memory lists: its per-element closure overhead makes it *slower* than eager `Enum` there, and a `Stream` that's never run does nothing. The rule of thumb: `Stream` for large/lazy/early-exit pipelines, `Enum` for small concrete collections.

```elixir
# Large file: stream lines so you never hold the whole file in memory,
# fuse the transformations, and stop after 100 matches.
"orders.csv"
|> File.stream!()
|> Stream.map(&parse_row/1)
|> Stream.filter(&(&1.total > 1_000))
|> Enum.take(100)          # a terminal Enum call is what actually runs the stream

# Small list already in memory: plain Enum is clearer and faster.
users |> Enum.filter(& &1.active?) |> Enum.map(& &1.email)
```

Reference: [Elixir — `Stream`](https://hexdocs.pm/elixir/Stream.html)
