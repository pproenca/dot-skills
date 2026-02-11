---
title: Eager Load ActiveRecord Associations
impact: HIGH
impactDescription: eliminates N+1 queries, reduces from 2N+1 to 3 queries
tags: io, eager-loading, n-plus-one, activerecord
---

## Eager Load ActiveRecord Associations

Accessing associations inside a loop without eager loading fires a separate SQL query per record. For 100 orders with comments, this means 101 queries instead of 2. Use `includes` to load all associated records in a single additional query.

**Incorrect (fires a query per iteration):**

```ruby
class OrderSummaryService
  def generate(user)
    orders = user.orders.where(status: :completed)

    orders.map do |order|
      {
        id: order.id,
        total: order.total,
        comments: order.comments.map(&:body),  # SELECT * FROM comments WHERE order_id = ? (per order)
        items_count: order.line_items.size       # SELECT COUNT(*) FROM line_items WHERE order_id = ? (per order)
      }
    end
  end
end
```

**Correct (three queries total regardless of record count):**

```ruby
class OrderSummaryService
  def generate(user)
    orders = user.orders
      .where(status: :completed)
      .includes(:comments, :line_items)

    orders.map do |order|
      {
        id: order.id,
        total: order.total,
        comments: order.comments.map(&:body),
        items_count: order.line_items.size
      }
    end
  end
end
```
