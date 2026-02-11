---
title: Use sort_by Instead of sort with Block
impact: MEDIUM
impactDescription: 2-5x faster for large collections via Schwartzian transform
tags: ds, sorting, sort-by, performance
---

## Use sort_by Instead of sort with Block

`sort` with a comparison block calls the block O(n log n) times, recomputing the sort key on every comparison. `sort_by` computes each key exactly once (Schwartzian transform), then sorts by the cached values. For collections where the key extraction is non-trivial (attribute access, string operations, method calls), `sort_by` is 2-5x faster.

**Incorrect (key recomputed on every comparison):**

```ruby
products = catalog.sort { |a, b|
  a.name.downcase <=> b.name.downcase  # downcase called O(n log n) times
}

orders = user.orders.sort { |a, b|
  a.created_at <=> b.created_at  # Method dispatch on every comparison
}
```

**Correct (key computed once per element):**

```ruby
products = catalog.sort_by { |product|
  product.name.downcase  # downcase called exactly N times, then cached
}

orders = user.orders.sort_by(&:created_at)  # Single pass for key extraction
```

**For descending order:**

```ruby
# Numeric keys — negate
products.sort_by { |p| -p.price }

# Non-numeric keys — reverse after sort
products.sort_by { |p| p.name.downcase }.reverse
```
