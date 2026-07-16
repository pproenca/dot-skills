---
title: Return only the documented run/3 shapes — a bare value is a failure
tags: step, run, return-contract, callbacks
---

## Return only the documented run/3 shapes — a bare value is a failure

`run/3` admits exactly six returns: `{:ok, value}`, `{:ok, value, [steps]}`,
`{:error, reason}`, `:retry`, `{:retry, reason}`, and `{:halt, reason}`.
Anything else — a bare computed value, a bare `:ok` from a fire-and-forget
call, an `{:ok, a, b}` where `b` is not a list of steps — is not a success
with a funny shape; the engine treats it as a failure. The step's actual work
*completed*, and then compensation and rollback fire for a "failure" that was
a formatting mistake, undoing real work. The habit comes from plain Elixir,
where returning the value is the contract; inside a Reactor step, the tuple is
the contract.

**Evidence of violation:** the return expression of a `run` fn or `run/3`
callback that is not one of the six documented shapes — a pipeline ending in
the raw value, a clause ending in `:ok`, a multi-element tuple whose third
element is not a list of steps. Every exit path of every clause counts. PASS:
all `run` return paths produce documented shapes. N/A: the target contains no
step implementations.

```elixir
@impl true
def run(%{order: order}, _context, _options) do
  case Fulfillment.dispatch(order) do
    {:ok, shipment} -> {:ok, shipment}
    # Passing the provider's error through keeps the shape valid.
    {:error, reason} -> {:error, reason}
  end
end
```

Reference: [Reactor.Step — run/3 return types](https://reactor.hexdocs.pm/Reactor.Step.html)
