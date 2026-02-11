---
title: Use exists? Instead of count for Existence Checks
impact: HIGH
impactDescription: 2-10× faster than COUNT(*) on large tables
tags: db, exists, count, query-optimization
---

## Use exists? Instead of count for Existence Checks

`count > 0` forces the database to count every matching row. `exists?` stops at the first match and returns immediately.

**Incorrect (counts all matching rows):**

```ruby
if Order.where(user_id: current_user.id, status: "pending").count > 0
  redirect_to checkout_path
end
```

**Correct (stops at first match):**

```ruby
if Order.where(user_id: current_user.id, status: "pending").exists?
  redirect_to checkout_path
end
```

**Alternative (use `any?` for loaded relations):**

```ruby
if current_user.orders.loaded? && current_user.orders.any?(&:pending?)
  redirect_to checkout_path
end
```

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#existence-of-objects)
