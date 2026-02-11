---
title: Use map/select/reject Over each with Accumulator
impact: HIGH
impactDescription: eliminates mutable accumulator pattern
tags: idiom, enumerable, functional, map, select
---

## Use map/select/reject Over each with Accumulator

The `each`-with-accumulator pattern introduces unnecessary mutability and obscures intent. Ruby's Enumerable methods (`map`, `select`, `reject`) declare *what* you want in a single expression, eliminating temporary variables and off-by-one mutation bugs.

**Incorrect (mutable accumulator with each):**

```ruby
class OrderReport
  def line_item_totals(order)
    totals = []
    order.line_items.each do |item|
      totals << item.price * item.quantity  # mutable accumulator hides intent
    end
    totals
  end

  def active_users(users)
    results = []
    users.each do |user|
      results << user if user.active? && user.confirmed?  # manual filtering
    end
    results
  end

  def deactivated_emails(users)
    emails = []
    users.each do |user|
      emails << user.email unless user.active?
    end
    emails
  end
end
```

**Correct (declarative Enumerable methods):**

```ruby
class OrderReport
  def line_item_totals(order)
    order.line_items.map { |item| item.price * item.quantity }  # map declares transformation
  end

  def active_users(users)
    users.select { |user| user.active? && user.confirmed? }  # select declares filter criteria
  end

  def deactivated_emails(users)
    users.reject(&:active?).map(&:email)  # reject + map chains read as a pipeline
  end
end
```
