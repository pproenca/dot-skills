---
title: Give every externally-visible side effect an undo
tags: saga, undo, rollback, side-effects
---

## Give every externally-visible side effect an undo

Reactor only reverses what steps teach it to reverse. When a later step fails,
the engine walks completed steps backwards and calls `undo/4` on the ones that
have it — a step without `undo` is simply skipped, and its side effect survives
the rollback: the inventory stays reserved, the payment authorization stays
open, the row stays inserted. The default a developer carries in — "it's a saga
library, failure undoes my work" — is exactly backwards: writing the step *is*
opting in, writing `undo/4` is what makes it reversible.

**Evidence of violation:** a step whose `run` performs an externally-visible
write (a `Repo.insert`/`update`/`delete`, a payment or reservation API call, an
HTTP POST/PUT/DELETE, a file write, publishing a message) in a reactor where at
least one step can run after it, with no `undo` — neither a `def undo` in the
step module nor an `undo` option on the DSL step. PASS: every such step defines
`undo/4` (or the DSL `undo` fn), or is the reactor's terminal step with nothing
after it to fail. N/A: no step in the target performs an externally-visible
write. Carve-out (citable): the effect is append-only/immutable by design and a
comment, moduledoc, or reconciliation path states that leaving it is acceptable
— cite it; an uncited assumption that leaving the effect is fine is FAIL.

```elixir
defmodule Checkout.ReserveInventory do
  use Reactor.Step

  @impl true
  def run(%{order: order}, _context, _options) do
    Inventory.reserve(order.items)
  end

  # Runs when this step succeeded but a later step failed:
  # release the reservation so rollback leaves no orphaned hold.
  @impl true
  def undo(reservation, _arguments, _context, _options) do
    case Inventory.release(reservation) do
      :ok -> :ok
      {:error, :already_released} -> :ok
    end
  end
end
```

Reference: [Reactor — Error Handling: compensation and undo](https://reactor.hexdocs.pm/02-error-handling.html)
