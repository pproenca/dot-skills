---
title: Never create atoms from external input
tags: conc, atoms, security, denial-of-service
---

## Never create atoms from external input

Atoms are never garbage collected and the atom table is bounded (~1,048,576 by default); when it fills, the whole VM crashes. So `String.to_atom/1`, `List.to_atom/1`, and passing `keys: :atoms` to a JSON/config parser on **untrusted** input is a denial-of-service vector: an attacker sends distinct strings until the node dies. Use `String.to_existing_atom/1`, which only resolves atoms that **already exist** in the atom table (and raises `ArgumentError` otherwise), or keep external keys as strings / map them through an explicit allowlist. This applies to params, request bodies, headers, message payloads — anything from outside the system.

**Correct (resolve only against atoms that already exist):**

```elixir
# Params come from the outside world — resolve against known atoms only.
@sortable_fields ~w(inserted_at total status)a   # these atoms now exist at compile time

def sort_field(param) when is_binary(param) do
  case String.to_existing_atom(param) do
    field when field in @sortable_fields -> {:ok, field}
    _ -> {:error, :invalid_sort}
  end
rescue
  ArgumentError -> {:error, :invalid_sort}   # unknown string never becomes a new atom
end
```

**Incorrect (unbounded atom creation from user input):**

```elixir
def sort_field(param), do: String.to_atom(param)   # attacker can exhaust the atom table
```

Reference: [Elixir — Code anti-patterns: "Dynamic atom creation"](https://hexdocs.pm/elixir/code-anti-patterns.html#dynamic-atom-creation) · [`String.to_existing_atom/1`](https://hexdocs.pm/elixir/String.html#to_existing_atom/1)
