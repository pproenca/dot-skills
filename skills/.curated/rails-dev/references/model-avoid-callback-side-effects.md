---
title: Avoid Side Effects in Model Callbacks
impact: HIGH
impactDescription: prevents hidden failures in saves, seeds, and tests
tags: model, callbacks, side-effects, predictability
---

## Avoid Side Effects in Model Callbacks

Callbacks that send emails, call APIs, or enqueue jobs run on every save — including seeds, tests, and console updates. Extract side effects into explicit service calls.

**Incorrect (side effects in callback):**

```ruby
class Order < ApplicationRecord
  after_create :send_confirmation_email
  after_create :reserve_inventory
  after_create :notify_warehouse

  private

  def send_confirmation_email
    OrderMailer.confirmation(self).deliver_later  # Fires on seeds and tests
  end

  def reserve_inventory
    InventoryService.reserve(line_items)  # Fires on console creates
  end

  def notify_warehouse
    WarehouseApi.notify(self)  # External API on every create
  end
end
```

**Correct (explicit service call):**

```ruby
class Order < ApplicationRecord
  # Only data-integrity callbacks in model
  before_validation :normalize_status
end

# app/services/orders/place_order.rb
class Orders::PlaceOrder
  def self.call(order:)
    return false unless order.save

    OrderMailer.confirmation(order).deliver_later
    InventoryService.reserve(order.line_items)
    WarehouseApi.notify(order)
    true
  end
end
```

**When NOT to use this pattern:**
- Data normalization callbacks (before_validation) are fine
- Touching parent timestamps (after_save :touch) is appropriate
- Counter cache updates belong in callbacks

Reference: [Active Record Callbacks — Rails Guides](https://guides.rubyonrails.org/active_record_callbacks.html)
