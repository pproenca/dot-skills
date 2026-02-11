---
title: Use Enums for Finite State Fields
impact: MEDIUM-HIGH
impactDescription: eliminates string comparisons, 2× faster lookups via integer storage
tags: model, enums, state-management, type-safety
---

## Use Enums for Finite State Fields

Storing status as raw strings allows typos and inconsistent values. Enums provide predefined states with query scopes and predicate methods.

**Incorrect (raw string status field):**

```ruby
class Order < ApplicationRecord
end

# Prone to typos and inconsistency
order.update(status: "shiped")  # Typo saved to DB
Order.where(status: "pending")
order.status == "pending"  # String comparison everywhere
```

**Correct (enum with predefined states):**

```ruby
class Order < ApplicationRecord
  enum :status, {
    pending: 0,
    confirmed: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }
end

order.shipped!           # Transition method
order.shipped?           # Predicate method
Order.shipped            # Auto-generated scope
Order.where.not(status: :cancelled)
```

**Benefits:**
- Stored as integers (faster queries, less storage)
- Auto-generated scopes, predicates, and bang methods
- Invalid values raise ArgumentError

Reference: [Active Record Enums — Rails API](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html)
