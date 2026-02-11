---
title: Avoid Database Queries Inside Loops
impact: HIGH
impactDescription: reduces N queries to 1 bulk query
tags: io, loops, bulk, queries, activerecord
---

## Avoid Database Queries Inside Loops

Issuing a `find` or `where` call inside a loop sends a separate SQL query per iteration. For 200 IDs, that is 200 round trips to the database. Load all records in a single bulk query and index them for O(1) lookup.

**Incorrect (one query per iteration):**

```ruby
class OrderFulfillmentService
  def fulfill(order_ids)
    order_ids.each do |id|
      order = Order.find(id)                 # SELECT * FROM orders WHERE id = ? (per id)
      product = Product.find(order.product_id)  # SELECT * FROM products WHERE id = ? (per order)
      ship(order, product)
    end
  end
end
```

**Correct (two bulk queries, then in-memory lookup):**

```ruby
class OrderFulfillmentService
  def fulfill(order_ids)
    orders = Order.where(id: order_ids).index_by(&:id)
    product_ids = orders.values.map(&:product_id).uniq
    products = Product.where(id: product_ids).index_by(&:id)

    order_ids.each do |id|
      order = orders[id]
      product = products[order.product_id]
      ship(order, product)
    end
  end
end
```
