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
require "forwardable"

class Order
  extend Forwardable

  # Expose only what callers need — internal structure stays private
  def_delegators :customer, :email, :customer_city, :customer_postal_code
end

class Customer
  extend Forwardable

  def_delegators :address, :city, :postal_code

  def customer_city = city
  def customer_postal_code = postal_code
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

In Rails, replace `extend Forwardable` / `def_delegators` with the built-in `delegate`:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  # Rails delegate — same effect, less boilerplate
  delegate :email, to: :customer
  delegate :city, :postal_code, to: :customer, prefix: true
end
```
