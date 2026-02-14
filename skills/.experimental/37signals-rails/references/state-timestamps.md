---
title: Timestamps for State Transitions
impact: HIGH
impactDescription: enables direct SQL queries and indexing on state
tags: state, timestamps, transitions, nullable
---

## Timestamps for State Transitions

Use nullable timestamp columns (`completed_at`, `deactivated_at`, `read_at`) to represent state instead of booleans or string columns. A null `completed_at` means incomplete; a present value means done and tells you exactly when. This pattern is queryable, indexable, and encodes both state and timing in a single column.

**Incorrect (boolean or enum for binary state):**

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  # Boolean loses "when" — you only know "if"
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  def complete!
    update!(completed: true)
    # When was it completed? No idea without a separate column.
  end
end

# app/models/notification.rb
class Notification < ApplicationRecord
  # String column with no type safety
  # status can drift: "read", "Read", "READ", "seen"
  scope :unread, -> { where(status: "unread") }

  def mark_as_read!
    update!(status: "read")
  end
end
```

**Correct (nullable timestamps encoding state + timing):**

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def complete!
    update!(completed_at: Time.current)
  end

  def uncomplete!
    update!(completed_at: nil)
  end

  def completed?
    completed_at.present?
  end
end

# app/models/notification.rb
class Notification < ApplicationRecord
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  def mark_as_read!
    update!(read_at: Time.current)
  end

  def read?
    read_at.present?
  end
end

# Queries are fast and expressive:
# Todo.completed.where(completed_at: 1.week.ago..)
# Notification.unread.where(created_at: ..1.day.ago)
```

**Alternative — multiple timestamps for lifecycle tracking:**

```ruby
# app/models/subscription.rb
class Subscription < ApplicationRecord
  # Each timestamp captures a lifecycle event
  # activated_at, paused_at, cancelled_at, expired_at

  scope :active, -> { where.not(activated_at: nil).where(cancelled_at: nil, expired_at: nil) }
  scope :paused, -> { where.not(paused_at: nil).where(cancelled_at: nil) }

  def active?
    activated_at.present? && cancelled_at.nil? && expired_at.nil?
  end
end
```

**When NOT to use:**
- When state has more than 2-3 values and you need mutual exclusivity (e.g., `draft`, `published`, `archived`, `trashed`) — use an enum instead, since multiple timestamp columns become unwieldy and can conflict.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
