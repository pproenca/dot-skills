---
title: Never mint atoms from external input
tags: mech, atoms, dos, input-validation
---

## Never mint atoms from external input

Atoms live in a VM-global table that is never garbage collected and has a fixed limit (about a million by default); when it fills, the node crashes. `String.to_atom/1` on anything an outsider influences — request params, decoded payloads, header names, file contents — hands that outsider a write handle to the table: a script iterating random strings kills the node with plain traffic. The safe conversions already exist and cost nothing: `String.to_existing_atom/1` raises instead of minting (correct when the value must be one of your already-compiled atoms), an explicit mapping makes the closed set visible, and very often the string never needed to become an atom at all.

**Evidence of violation:** `String.to_atom/1`, `:erlang.binary_to_atom/1,2`, `:erlang.list_to_atom/1`, or decoder options that atomize keys (`Jason.decode(..., keys: :atoms)` and equivalents) applied to data originating outside the system — request params or bodies, queue/socket payloads, third-party API responses, runtime-read file or environment content. PASS: `String.to_existing_atom/1` (or `keys: :atoms!`) where the set is closed by compiled code; an explicit whitelist map from string to atom; or keeping the value a string throughout. N/A: no string-to-atom conversion in the target. Carve-out (citable): the input is provably internal and bounded — compile-time configuration, a migration over a fixed column set, a controlled admin tool — cite the source and what bounds it; "clients send well-known values" is trust, not a bound.

```elixir
@statuses %{"pending" => :pending, "shipped" => :shipped, "cancelled" => :cancelled}

def parse_status(param) do
  # The closed set is visible and unknown input becomes an error value,
  # not a permanent entry in a table that outlives the request by forever.
  case Map.fetch(@statuses, param) do
    {:ok, status} -> {:ok, status}
    :error -> {:error, :invalid_status}
  end
end
```

Reference: [Elixir `String.to_atom/1` — atom exhaustion warning](https://hexdocs.pm/elixir/String.html#to_atom/1)
