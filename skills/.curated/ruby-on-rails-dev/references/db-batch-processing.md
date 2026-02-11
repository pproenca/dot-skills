---
title: Use find_each for Large Dataset Iteration
impact: CRITICAL
impactDescription: constant memory vs O(n) memory growth
tags: db, batch-processing, find-each, memory
---

## Use find_each for Large Dataset Iteration

Loading thousands of records with `.all.each` loads every record into memory at once. Use `find_each` to process records in batches of 1,000.

**Incorrect (loads all records into memory):**

```ruby
User.where(active: true).each do |user|
  UserMailer.weekly_digest(user).deliver_later  # 100k User objects in memory
end
```

**Correct (processes in batches of 1,000):**

```ruby
User.where(active: true).find_each do |user|
  UserMailer.weekly_digest(user).deliver_later
end
```

**Alternative (custom batch size and access to batch):**

```ruby
User.where(active: true).find_in_batches(batch_size: 500) do |batch|
  UserMailer.bulk_digest(batch.map(&:id)).deliver_later
end
```

Reference: [Active Record Query Interface — Rails Guides](https://guides.rubyonrails.org/active_record_querying.html#retrieving-multiple-objects-in-batches)
