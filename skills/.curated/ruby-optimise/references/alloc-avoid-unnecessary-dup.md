---
title: Avoid Unnecessary Object Duplication
impact: CRITICAL
impactDescription: eliminates redundant allocations in hot paths
tags: alloc, dup, clone, memory
---

## Avoid Unnecessary Object Duplication

Calling `.dup` or `.clone` inside loops creates a new heap object per iteration, multiplying GC pressure linearly with the collection size. Freeze shared objects once and reference them directly, or restructure the logic to avoid duplication entirely.

**Incorrect (allocates a new object per iteration):**

```ruby
class OrderExporter
  HEADER_TEMPLATE = ["Order ID", "Customer", "Total", "Status"]

  def export(orders)
    rows = []
    orders.each do |order|
      header = HEADER_TEMPLATE.dup  # Allocates a new array every iteration
      rows << header
      rows << [order.id, order.customer_name, order.total, order.status]
    end
    rows
  end
end
```

**Correct (zero per-iteration allocations):**

```ruby
class OrderExporter
  HEADER_TEMPLATE = ["Order ID", "Customer", "Total", "Status"].freeze

  def export(orders)
    rows = []
    orders.each do |order|
      rows << HEADER_TEMPLATE
      rows << [order.id, order.customer_name, order.total, order.status]
    end
    rows
  end
end
```

**When `.dup` IS appropriate:**
- When the caller will mutate the returned object
- When building a modified copy from a template (but do it outside the loop)
- When passing data across thread boundaries that requires isolation
