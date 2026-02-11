---
title: Avoid Database Queries Inside Loops
impact: CRITICAL
impactDescription: reduces N queries to 1 query
tags: db, n-plus-one, loops, where-in
---

## Avoid Database Queries Inside Loops

Executing queries inside loops creates N+1 patterns even without associations. Collect IDs first, then query once.

**Incorrect (1 query per iteration):**

```ruby
order_ids = [1, 5, 23, 42, 99]
order_ids.each do |id|
  order = Order.find(id)  # 5 separate SELECT queries
  process_order(order)
end
```

**Correct (single query with where):**

```ruby
order_ids = [1, 5, 23, 42, 99]
orders = Order.where(id: order_ids).index_by(&:id)
order_ids.each do |id|
  process_order(orders[id])
end
```

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html)
