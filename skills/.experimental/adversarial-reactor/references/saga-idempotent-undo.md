---
title: Make undo idempotent — already-gone is success
tags: saga, undo, idempotency, rollback
---

## Make undo idempotent — already-gone is success

`undo/4` can run more than once: it may return `:retry`, the resource may have
been reaped by a timeout on the remote side, or a previous partial rollback may
have already removed it. The wrong default is treating "already gone" as a
failure — propagating `{:error, :not_found}` or `{:error, :already_voided}` —
which fails the rollback precisely when its goal is already achieved, leaving
the saga wedged half-undone. Undo's postcondition is "the effect is absent",
not "this call removed it": any error that means the effect is already absent
is a success.

**Evidence of violation:** an `undo/4` (or DSL `undo` fn) that returns
`{:error, _}` for already-absent outcomes — `:not_found`, `:already_voided`,
`:already_released`, `:already_deleted`, an HTTP 404/410 from the delete call —
instead of mapping them to `:ok`; or an undo that re-raises on a second
invocation (e.g. `Repo.delete!` on a missing row). PASS: every undo maps
already-absent outcomes to `:ok`, by explicit clause or by using an idempotent
delete. N/A: no undo callbacks in the target.

```elixir
@impl true
def undo(reservation, _arguments, _context, _options) do
  case Inventory.release(reservation) do
    :ok -> :ok
    # The reservation is already gone — undo's goal is met.
    {:error, :not_found} -> :ok
    {:error, :already_released} -> :ok
    {:error, reason} -> {:error, reason}
  end
end
```

Reference: [Reactor — Error Handling: undo idempotency](https://reactor.hexdocs.pm/02-error-handling.html)
