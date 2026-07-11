---
title: Dispatch on type with a protocol, not a hand-rolled case/is_* switch
tags: type, protocol, polymorphism, dispatch
---

## Dispatch on type with a protocol, not a hand-rolled case/is_* switch

Branching on a type tag — `case item.type do :book -> ...; :video -> ... end` — or on `is_binary/1`/`is_map/1` guards, is a manual reimplementation of polymorphism. The switch grows every time a new type appears, must be edited in every place the type is handled, and drifts out of sync between call sites (open/closed violation). A protocol dispatches on the data's type at the language level: each type provides its own implementation, and adding a type means adding an `defimpl` — no caller changes.

**Evidence of violation:** a `case`/`cond` on a type tag (`item.type`, `%{__struct__: _}`) or a chain of `is_binary/is_map/is_list` guards selecting behavior per type, where the same type set is dispatched on in two or more modules (requires searching beyond the diff for the duplicate — the repo root is stated in the review target), or the variant set is open (new types are added by users/config/other apps). PASS: an existing protocol with `defimpl` per type, or dispatch via distinct function heads matching struct types inside the type set's owning module. N/A: no type-based dispatch in the target. Carve-out (in the rule): a small closed set (two or three variants owned by one module, dispatched in exactly one place) is fine inline — the duplication or openness is what decides FAIL, so cite the second dispatch site or the open-set mechanism.

```elixir
defprotocol MyApp.Priceable do
  def price(item)
end

defimpl MyApp.Priceable, for: MyApp.Catalog.Book do
  def price(%{base: base}), do: base
end

defimpl MyApp.Priceable, for: MyApp.Catalog.Subscription do
  def price(%{monthly: m, months: n}), do: m * n
end

# Caller is type-agnostic and never edited when a new item type is added.
total = items |> Enum.map(&MyApp.Priceable.price/1) |> Enum.sum()
```

**When a `case` is fine:** a small, closed set of variants that won't grow (two or three states owned by one module) is clearer inline. Reach for a protocol when the type set is open or the dispatch is duplicated across modules.

Reference: [Elixir — Protocols](https://hexdocs.pm/elixir/protocols.html)
