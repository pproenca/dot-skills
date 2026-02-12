---
title: Use Consistent Opaque Identifiers Across Resources
impact: CRITICAL
impactDescription: prevents enumeration attacks, enables distributed ID generation
tags: res, identifiers, uuid, security, uri-design
---

## Use Consistent Opaque Identifiers Across Resources

Never expose auto-increment integer IDs in URIs. Sequential IDs reveal record counts, enable enumeration attacks, and tie your API to a single database's sequence. Use prefixed UUIDs or opaque identifiers that are consistent across all resources.

**Incorrect (sequential integer IDs expose internal state):**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  # Uses default auto-increment ID
  # URI: /orders/42 -- attacker can guess /orders/41, /orders/43
end

# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  def show
    order = Order.find(params[:id])  # sequential integer lookup

    render json: {
      id: order.id,  # exposes 42, 43, 44 ...
      total: order.total,
      _links: {
        self: { href: "/orders/#{order.id}" }
      }
    }
  end
end
```

**Correct (prefixed opaque identifiers prevent enumeration):**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  before_create :assign_public_id

  def to_param
    public_id  # Rails uses this for URL generation
  end

  private

  def assign_public_id
    self.public_id = "ord_#{SecureRandom.uuid.delete('-')}"  # e.g. ord_8f3a2b4c5d6e7f8a9b0c
  end
end

# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  def show
    order = Order.find_by!(public_id: params[:id])

    render json: {
      id: order.public_id,
      total: order.total,
      _links: {
        self: { href: order_path(order) }  # /orders/ord_8f3a2b4c5d6e7f8a9b0c
      }
    }
  end
end
```

**Benefits:**
- Opaque IDs prevent competitors or attackers from guessing resource counts or scraping sequentially
- Prefixed IDs (`ord_`, `cust_`) are self-describing in logs and debugging
- UUIDs enable distributed ID generation without central sequence coordination

**When NOT to use:** Internal admin dashboards behind authentication may use integer IDs for convenience, but public-facing APIs should always use opaque identifiers.
