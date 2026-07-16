---
title: Return {:continue, value} from compensate to absorb an error — :ok still rolls back
tags: saga, compensate, continue, error-handling
---

## Return {:continue, value} from compensate to absorb an error — :ok still rolls back

`:ok` from `compensate/4` reads like "handled, carry on" — it is not. It means
"successfully compensated", and the reactor still fails and undoes upstream
steps. The only compensate return that keeps the reactor running is
`{:continue, value}`, which substitutes `value` as the step's result and lets
execution proceed. The wrong default is computing a fallback inside compensate
and returning `:ok`, believing the error was absorbed: the fallback is thrown
away, the whole reactor rolls back, and the caller gets `{:error, _}` for a
failure the developer thought was recovered.

**Evidence of violation:** a `compensate/4` (or DSL `compensate` fn) that
returns `:ok` alongside at least one cited recovery anchor: (a) a
fallback/default value computed in the compensate body and then discarded,
(b) a comment stating the error is handled/non-fatal/recoverable, or (c) a
caller or test asserting `{:ok, _}` from `Reactor.run` on that failure path.
The verdict is decided by the anchors — FAIL requires citing at least one;
with none of the three present, the `:ok` is read as intentional
give-up-and-roll-back and the rule is N/A for that callback, never FAIL on an
inferred "design intent". PASS: recoverable failures return
`{:continue, fallback}`. N/A: no compensate callback in the target, or none
with a citable recovery anchor.

```elixir
defmodule Enrichment.FetchRecommendations do
  use Reactor.Step

  @impl true
  def run(%{user: user}, _context, _options) do
    Recommendations.fetch(user.id)
  end

  # Recommendations are optional: substitute an empty list and keep the
  # reactor running. Returning :ok here would roll the whole run back.
  @impl true
  def compensate(_reason, _arguments, _context, _options) do
    {:continue, []}
  end
end
```

Reference: [Reactor — Error Handling: compensation outcomes](https://reactor.hexdocs.pm/02-error-handling.html)
