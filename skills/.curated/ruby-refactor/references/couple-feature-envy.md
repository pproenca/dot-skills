---
title: Move Method to Resolve Feature Envy
impact: HIGH
impactDescription: reduces cross-class coupling from N accessors to 1 method call
tags: couple, feature-envy, move-method, cohesion
---

## Move Method to Resolve Feature Envy

When a method reaches into another object for most of its data, the logic belongs on that object. Feature envy scatters related calculations across classes, so a change to the data structure forces edits in every envious caller. Moving the method next to the data it uses eliminates this coupling.

**Incorrect (OrderPrinter reaches into Order for every value):**

```ruby
class OrderPrinter
  def format_total(order)
    # Every line pulls data from order — this method envies Order
    subtotal = order.items.sum { |item| item.price * item.quantity }
    discount = subtotal * order.discount_rate
    tax = (subtotal - discount) * order.tax_rate
    total = subtotal - discount + tax

    "Subtotal: #{subtotal}, Discount: #{discount}, Tax: #{tax}, Total: #{total}"
  end
end
```

**Correct (calculation moves to Order, printer only formats):**

```ruby
class Order
  def subtotal
    items.sum { |item| item.price * item.quantity }
  end

  def discount
    subtotal * discount_rate
  end

  def tax
    (subtotal - discount) * tax_rate
  end

  # Data and logic live together — one place to change
  def total
    subtotal - discount + tax
  end
end

class OrderPrinter
  def format_total(order)
    "Subtotal: #{order.subtotal}, Discount: #{order.discount}, " \
      "Tax: #{order.tax}, Total: #{order.total}"
  end
end
```
