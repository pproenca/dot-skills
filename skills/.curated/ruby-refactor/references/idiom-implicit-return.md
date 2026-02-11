---
title: Omit Explicit return for Last Expression
impact: MEDIUM-HIGH
impactDescription: follows Ruby convention, reduces noise
tags: idiom, return, convention, readability
---

## Omit Explicit return for Last Expression

Ruby methods implicitly return the value of their last expression. Adding an explicit `return` at the end of a method is redundant noise that signals the author may not be fluent in Ruby conventions. Keep explicit `return` only for early exits (guard clauses) where it communicates intent to short-circuit.

**Incorrect (redundant return on last expression):**

```ruby
class PricingCalculator
  def total_price(order)
    subtotal = order.line_items.sum(&:total)
    discount = calculate_discount(order.customer, subtotal)
    tax = (subtotal - discount) * tax_rate(order.shipping_address)
    return subtotal - discount + tax  # redundant — already the last expression
  end

  def tax_rate(address)
    return address.state == "OR" ? 0.0 : 0.08  # redundant return
  end

  def formatted_total(order)
    total = total_price(order)
    return "$#{'%.2f' % total}"  # redundant return
  end
end
```

**Correct (implicit return, explicit only for guard clauses):**

```ruby
class PricingCalculator
  def total_price(order)
    subtotal = order.line_items.sum(&:total)
    discount = calculate_discount(order.customer, subtotal)
    tax = (subtotal - discount) * tax_rate(order.shipping_address)
    subtotal - discount + tax  # implicit return — idiomatic Ruby
  end

  def tax_rate(address)
    address.state == "OR" ? 0.0 : 0.08
  end

  def formatted_total(order)
    total = total_price(order)
    "$#{'%.2f' % total}"
  end

  def apply_coupon(order, code)
    return 0 unless code.present?  # explicit return is correct here — guard clause
    return 0 if coupon_expired?(code)

    Coupon.find_by(code: code).discount_amount
  end
end
```
