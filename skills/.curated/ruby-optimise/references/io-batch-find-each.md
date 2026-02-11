---
title: Use find_each for Large Record Sets
impact: HIGH
impactDescription: O(1000) memory vs O(n) for entire table
tags: io, batch, find-each, activerecord, memory
---

## Use find_each for Large Record Sets

`User.all.each` loads every record into memory before iteration begins. For tables with millions of rows, this can exhaust available RAM and crash the process. `find_each` fetches records in batches of 1000 (configurable), keeping memory usage constant regardless of table size.

**Incorrect (loads entire table into memory at once):**

```ruby
class AccountCleanupJob
  def perform
    User.where("last_login_at < ?", 2.years.ago).each do |user|  # loads all matching rows into memory
      user.anonymize_personal_data!
      user.update!(status: :archived)
    end
  end
end
```

**Correct (processes in batches with constant memory):**

```ruby
class AccountCleanupJob
  def perform
    User.where("last_login_at < ?", 2.years.ago).find_each(batch_size: 500) do |user|
      user.anonymize_personal_data!
      user.update!(status: :archived)
    end
  end
end
```
