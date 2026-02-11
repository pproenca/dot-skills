---
title: Avoid Temporary Array Creation
impact: HIGH
impactDescription: eliminates N intermediate allocations per iteration
tags: alloc, arrays, temporary, memory
---

## Avoid Temporary Array Creation

Splat operators (`*args`) and array-wrapping patterns silently allocate intermediate arrays on every call. In hot paths, this creates thousands of throwaway objects that pressure the GC. Pass arguments directly or use `Array()` only when the input type genuinely varies.

**Incorrect (splat creates a temporary array per call):**

```ruby
class NotificationService
  def notify_all(users, message)
    users.each do |user|
      send_notification(*build_params(user, message))  # Allocates throwaway array per user
    end
  end

  private

  def build_params(user, message)
    [user.email, message.subject, message.body]  # Array allocated and immediately unpacked
  end
end
```

**Correct (pass arguments directly):**

```ruby
class NotificationService
  def notify_all(users, message)
    users.each do |user|
      send_notification(user.email, message.subject, message.body)
    end
  end
end
```

**Another common pattern -- unnecessary array construction via splat:**

**Incorrect (splat collects into throwaway array):**

```ruby
def process_line_items(order)
  items = *order.line_items  # Splat always allocates a new array, even if input is already an array
  items.each do |item|
    update_inventory(item)
  end
end
```

**Correct (iterate directly):**

```ruby
def process_line_items(order)
  order.line_items.each do |item|  # No intermediate allocation
    update_inventory(item)
  end
end
```
