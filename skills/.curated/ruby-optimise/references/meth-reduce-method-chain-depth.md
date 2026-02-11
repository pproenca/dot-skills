---
title: Reduce Method Chain Depth in Hot Loops
impact: MEDIUM
impactDescription: reduces N × depth dispatch calls to N × 1
tags: meth, chaining, dispatch, performance
---

## Reduce Method Chain Depth in Hot Loops

Deep method chains like `order.customer.address.city` perform multiple dispatches per access. Inside a loop, this overhead multiplies by the iteration count. Caching the terminal value in a local variable before the loop eliminates redundant traversals.

**Incorrect (repeated chain traversal on every iteration):**

```ruby
def shipping_labels(orders)
  labels = []
  orders.each do |order|
    labels << {
      recipient: order.customer.full_name,            # 2 dispatches per access
      street: order.customer.address.street,           # 3 dispatches per access
      city: order.customer.address.city,               # 3 dispatches per access
      postal_code: order.customer.address.postal_code  # 3 dispatches per access
    }
  end
  labels
end
```

**Correct (cache intermediate objects before accessing fields):**

```ruby
def shipping_labels(orders)
  orders.map do |order|
    customer = order.customer
    address = customer.address  # Single traversal to address

    {
      recipient: customer.full_name,
      street: address.street,
      city: address.city,
      postal_code: address.postal_code
    }
  end
end
```
