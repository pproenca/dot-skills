---
title: Enable allow_async? on map steps that do I/O — map is serial by default
tags: conc, map, async, throughput
---

## Enable allow_async? on map steps that do I/O — map is serial by default

Reactor's async defaults are inconsistent by design, and the exception is
`map`: `step`, `compose`, and `switch` default to async execution, but the
`map` entity's `allow_async?` defaults to **`false`** — every emitted per-item
step runs sequentially. A developer who has internalized "Reactor runs things
concurrently" writes a map over a thousand HTTP calls and ships a serial loop:
correct output, collapsed throughput, and nothing in the code that looks
wrong. When the per-item work is I/O-bound, the map must say `allow_async?
true`; the inverse mistake — enabling it over sandboxed DB work in tests —
trades an ownership error for the throughput.

**Evidence of violation:** a `map` block whose nested steps perform I/O (HTTP,
Repo, file) with no `allow_async? true` line — FAIL by default. Carve-out
(citable): a serial reason is present in the artifact — an ordering dependency
between items the reviewer can point to, or the map runs inside sandbox-backed
tests — cite it; an uncited assumption that serial was intended does not
excuse the absence. N/A: no `map` in the target, or nested steps are pure CPU
transforms where serial batching is the reasonable default.

```elixir
map :enrich_companies do
  source input(:companies)
  batch_size 100
  # Without this line the per-item HTTP calls run one at a time.
  allow_async? true

  step :fetch_firmographics, Enrichment.FetchFirmographics do
    argument :company, element(:enrich_companies)
  end

  return :fetch_firmographics
end
```

Reference: [Reactor DSL — map options and defaults](https://reactor.hexdocs.pm/dsl-reactor.html)
