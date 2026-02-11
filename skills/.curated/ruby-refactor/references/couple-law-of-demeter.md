---
title: Enforce Law of Demeter with Delegation
impact: HIGH
impactDescription: reduces coupling to 1 dependency per call
tags: couple, law-of-demeter, delegate, forwardable
---

## Enforce Law of Demeter with Delegation

Chained method calls like `order.customer.address.city` couple the caller to the entire object graph, so renaming or restructuring any intermediate object breaks every call site. Delegation exposes only what the caller needs, keeping each object's contract to a single dot.

**Incorrect (chained calls couple caller to 3 levels of structure):**

```ruby
class OrderMailer
  def send_confirmation(order)
    # Each dot is a dependency — 3 objects must stay stable
    city = order.customer.address.city
    email = order.customer.email
    postal_code = order.customer.address.postal_code

    deliver(
      to: email,
      subject: "Order confirmed",
      body: "Shipping to #{city}, #{postal_code}"
    )
  end
end
```

**Correct (delegate through the immediate collaborator):**

```ruby
class Order
  # Expose only what callers need — internal structure stays private
  delegate :email, to: :customer
  delegate :city, :postal_code, to: :customer, prefix: true
end

class OrderMailer
  def send_confirmation(order)
    city = order.customer_city
    email = order.email
    postal_code = order.customer_postal_code

    deliver(
      to: email,
      subject: "Order confirmed",
      body: "Shipping to #{city}, #{postal_code}"
    )
  end
end
```

**Alternative (stdlib Forwardable for non-Rails projects):**

```ruby
require "forwardable"

class Customer
  extend Forwardable
  def_delegators :address, :city, :postal_code
end
```
