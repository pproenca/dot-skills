---
title: Define Reusable Query Scopes on Models
impact: HIGH
impactDescription: eliminates query duplication across controllers
tags: db, scopes, query-composition, dry
---

## Define Reusable Query Scopes on Models

Repeating query conditions across controllers leads to inconsistency and duplication. Scopes encapsulate query logic in the model and compose cleanly.

**Incorrect (duplicated query logic in controllers):**

```ruby
# OrdersController
orders = Order.where(status: "pending").where("placed_at > ?", 30.days.ago)

# ReportsController
orders = Order.where(status: "pending").where("placed_at > ?", 30.days.ago)
```

**Correct (reusable scopes on model):**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { where("placed_at > ?", 30.days.ago) }
end

# Any controller
orders = Order.pending.recent
```

**Benefits:**
- Scopes are chainable and composable
- Single source of truth for query logic
- Testable in isolation

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#scopes)
