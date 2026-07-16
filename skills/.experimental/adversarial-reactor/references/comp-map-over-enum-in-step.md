---
title: Iterate collections with a map step, not Enum inside one step
tags: comp, map, iteration, batching
---

## Iterate collections with a map step, not Enum inside one step

`Enum.map(items, &process/1)` inside a single step turns N units of work into
one all-or-nothing blob: one item's failure fails the whole collection with no
per-item retry or compensation, nothing batches (the entire input and output
live in memory at once), and the planner sees one opaque step it can neither
parallelize nor partially roll back. The `map` entity is Reactor's word for
this shape — it emits per-item steps with `batch_size` chunking (default 100),
per-item saga semantics, and optional concurrency — and the data-pipelines
guide is explicit that procedural loops inside steps are to be avoided in
favor of `map`.

**Evidence of violation:** `Enum.map`/`Enum.each`/`Task.async_stream`/a `for`
comprehension over a collection-typed argument inside a `run` fn or `run/3`
body, where each element's work is independent (per-item API call, insert,
transformation pipeline). PASS: collection processing is expressed as `map`
blocks with nested steps. N/A: no step iterates a collection argument.
Carve-out (citable): the iteration is a single aggregate computation over
small in-memory data (a sum, a group-by feeding one result) rather than
per-item work — cite the reduction.

```elixir
map :import_contacts do
  source input(:contacts)
  batch_size 500

  step :insert_contact, Contacts.Insert do
    argument :contact, element(:import_contacts)
  end

  return :insert_contact
end
```

Reference: [Reactor — Data Pipelines tutorial](https://reactor.hexdocs.pm/data-pipelines.html)
