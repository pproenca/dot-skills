---
title: Preallocate Arrays When Size Is Known
impact: LOW-MEDIUM
impactDescription: avoids repeated resizing and memory copies
tags: ds, array, preallocation, memory
---

## Preallocate Arrays When Size Is Known

When the result size is known upfront, using `Array.new(n)` with a block allocates the correct capacity in a single step. Building an array with `<<` in a loop triggers multiple resize-and-copy cycles as the internal buffer grows (typically doubling at 0, 4, 8, 16, ...).

**Incorrect (repeated resizing as array grows):**

```ruby
def compute_monthly_totals(transactions, month_count)
  totals = []
  month_count.times do |i|
    month_transactions = transactions.select { |t| t.month_index == i }
    totals << month_transactions.sum(&:amount)  # Resizes at capacity boundaries
  end
  totals
end
```

**Correct (single allocation with exact size):**

```ruby
def compute_monthly_totals(transactions, month_count)
  Array.new(month_count) do |i|
    month_transactions = transactions.select { |t| t.month_index == i }
    month_transactions.sum(&:amount)  # No resizing needed
  end
end
```

**Also applies to map/collect:**

```ruby
# Already optimal — map preallocates based on receiver size
totals = transactions.map(&:amount)
```

**When preallocation matters most:**
- Large arrays (1000+ elements)
- Latency-sensitive code paths
- Memory-constrained environments
