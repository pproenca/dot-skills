---
title: "Tell Objects What to Do, Don't Query Their State"
impact: MEDIUM-HIGH
impactDescription: moves logic closer to data it depends on
tags: couple, tell-dont-ask, encapsulation, command
---

## Tell Objects What to Do, Don't Query Their State

Querying an object's internals to make a decision on its behalf scatters the object's business rules across every caller. When the rules change, every call site must be updated. Telling the object what to do keeps the decision and the data together, so changes happen in one place.

**Incorrect (caller queries state then acts on behalf of the object):**

```ruby
class PaymentProcessor
  def process(order)
    # Caller interrogates order internals — rules duplicated everywhere this pattern appears
    if order.status == :pending && order.total > 0
      order.payment_method.charge(order.total)
      order.status = :paid
      order.paid_at = Time.current
    elsif order.status == :pending && order.total.zero?
      order.status = :paid
      order.paid_at = Time.current
    end
  end
end
```

**Correct (tell the object to handle its own transition):**

```ruby
class Order
  def process_payment
    return unless status == :pending

    # Decision and data live together — one place to change
    payment_method.charge(total) unless total.zero?
    self.status = :paid
    self.paid_at = Time.current
  end
end

class PaymentProcessor
  def process(order)
    order.process_payment
  end
end
```
