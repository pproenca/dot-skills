---
title: Avoid Recomputing Collection Size in Conditions
impact: MEDIUM
impactDescription: "O(n) to O(1) per check for non-Array enumerables"
tags: enum, count, size, performance
---

## Avoid Recomputing Collection Size in Conditions

Using `.count > 0` or `.length > 0` to check for presence forces a full traversal on enumerables that lack a cached size (e.g., ActiveRecord relations, lazy enumerators, custom collections). `.any?` short-circuits on the first match, and `.empty?` avoids computing the total count.

**Incorrect (full traversal to check presence):**

```ruby
if order.line_items.count > 0            # executes SELECT COUNT(*) on every call
  apply_discount(order)
end

pending = users.select(&:pending?)
if pending.count == 0                     # already an array, but reads less clearly
  notify_admin("No pending users")
end

while unprocessed_jobs.count > 0          # O(n) recount on every loop iteration
  process(unprocessed_jobs.shift)
end
```

**Correct (short-circuit presence checks):**

```ruby
if order.line_items.any?                  # SELECT 1 ... LIMIT 1, stops immediately
  apply_discount(order)
end

pending = users.select(&:pending?)
if pending.empty?
  notify_admin("No pending users")
end

until unprocessed_jobs.empty?             # O(1) check per iteration
  process(unprocessed_jobs.shift)
end
```
