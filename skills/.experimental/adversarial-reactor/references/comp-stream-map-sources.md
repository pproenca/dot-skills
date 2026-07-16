---
title: Feed map steps a stream, not a fully materialized dataset
tags: comp, map, streaming, memory
---

## Feed map steps a stream, not a fully materialized dataset

`map`'s `batch_size` consumes the source lazily, a chunk at a time — but only
if the source is lazy. A producer step that does `File.read!(path) |>
String.split("\n")` or an unbounded `Repo.all(query)` materializes the entire
dataset in memory *before* the first batch is emitted, defeating the chunking
the map was configured for. The data-pipelines guide builds its sources from
`File.stream!` and lazy enumerables precisely so memory stays bounded by
`batch_size`, not by input size. The wrong default is eager loading, because
that is how one writes non-Reactor Elixir when the whole list is wanted at
once.

**Evidence of violation:** a `map` whose `source` is produced by
`File.read!` (plus split/decode) over a file of unbounded size, or a
`Repo.all`/full-table fetch with no limit, where a streaming equivalent
(`File.stream!`, `Repo.stream`, a paginated/lazy producer) exists. PASS: map
sources of unbounded inputs are streams or paginated producers. N/A: no `map`
in the target, or every source is bounded. Carve-out (citable): the input has
a hard, small size bound — cite the bound (a validation, a LIMIT, a domain
fact), not a hope.

```elixir
step :open_export do
  argument :path, input(:path)
  # Lazy: memory is bounded by batch_size, not file size.
  run fn %{path: path}, _ctx -> {:ok, File.stream!(path)} end
end

map :ingest_rows do
  source result(:open_export)
  batch_size 1_000

  step :insert_row, Exports.InsertRow do
    argument :row, element(:ingest_rows)
  end

  return :insert_row
end
```

Reference: [Reactor — Data Pipelines tutorial: streaming sources](https://reactor.hexdocs.pm/data-pipelines.html)
