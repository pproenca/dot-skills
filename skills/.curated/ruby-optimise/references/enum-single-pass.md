---
title: Use Single-Pass Collection Transforms
impact: CRITICAL
impactDescription: eliminates N intermediate arrays from chained methods
tags: enum, single-pass, chaining, arrays
---

## Use Single-Pass Collection Transforms

Chained `.select.map` creates a temporary array after each stage. For a collection of N elements, this allocates two full-size arrays and iterates twice. Single-pass alternatives like `filter_map` or `each_with_object` traverse once and allocate only the final result.

**Incorrect (multiple intermediate arrays):**

```ruby
active_emails = users
  .select { |user| user.confirmed? && user.active? }  # allocates intermediate array of active users
  .map(&:email)  # allocates second array of emails

discounted_totals = orders
  .select { |order| order.coupon_applied? }
  .map { |order| order.total * 0.85 }  # two passes, two throwaway arrays
```

**Correct (single-pass transform):**

```ruby
active_emails = users.filter_map { |user|
  user.email if user.confirmed? && user.active?  # one pass, one allocation
}

discounted_totals = orders.each_with_object([]) { |order, totals|
  totals << order.total * 0.85 if order.coupon_applied?
}
```
