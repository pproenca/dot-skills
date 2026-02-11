---
title: Use Hash Default Values Instead of Conditional Assignment
impact: LOW-MEDIUM
impactDescription: eliminates conditional branches and simplifies accumulation
tags: ds, hash, default, accumulation
---

## Use Hash Default Values Instead of Conditional Assignment

Manual nil-checking with `||=` or ternary operators before accumulating into a hash adds branching and visual noise. `Hash.new(default)` and `Hash.new { |h, k| h[k] = default }` handle missing keys automatically, producing cleaner code that eliminates an entire class of nil-related bugs.

**Incorrect (manual nil guard on every access):**

```ruby
def count_orders_by_status(orders)
  counts = {}
  orders.each do |order|
    counts[order.status] = (counts[order.status] || 0) + 1  # Nil check on every iteration
  end
  counts
end

def group_products_by_category(products)
  grouped = {}
  products.each do |product|
    grouped[product.category] ||= []         # Nil check before append
    grouped[product.category] << product
  end
  grouped
end
```

**Correct (default values handle missing keys automatically):**

```ruby
def count_orders_by_status(orders)
  counts = Hash.new(0)
  orders.each do |order|
    counts[order.status] += 1  # Returns 0 for missing keys
  end
  counts
end

def group_products_by_category(products)
  grouped = Hash.new { |h, k| h[k] = [] }
  products.each do |product|
    grouped[product.category] << product  # Auto-creates array for new keys
  end
  grouped
end
```

**Important:** Use `Hash.new(0)` for immutable defaults (integers, symbols). Use the block form `Hash.new { |h, k| h[k] = [] }` for mutable defaults to avoid sharing the same object across all keys.
