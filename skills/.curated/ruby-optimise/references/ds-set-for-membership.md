---
title: Use Set for Membership Tests
impact: MEDIUM
impactDescription: O(1) lookup vs O(n) with Array#include?
tags: ds, set, lookup, performance
---

## Use Set for Membership Tests

`Array#include?` scans elements linearly, making each lookup O(n). `Set#include?` uses a hash table internally, providing O(1) average-case lookups. For any collection checked repeatedly, the constant-time lookup dominates as size grows.

**Incorrect (linear scan on every check):**

```ruby
ALLOWED_STATUSES = ["active", "pending", "trialing"].freeze

def filter_eligible_users(users)
  users.select do |user|
    ALLOWED_STATUSES.include?(user.status)  # O(n) scan per user
  end
end
```

**Correct (constant-time hash lookup):**

```ruby
require "set"

ALLOWED_STATUSES = Set["active", "pending", "trialing"].freeze

def filter_eligible_users(users)
  users.select do |user|
    ALLOWED_STATUSES.include?(user.status)  # O(1) lookup per user
  end
end
```

**When to prefer Array:**
- Very small collections (< 5 elements) where linear scan is faster than hashing
- Ordered iteration is required
- Elements are not hashable
