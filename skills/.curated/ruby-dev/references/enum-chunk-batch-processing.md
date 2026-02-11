---
title: Use each_slice for Batch Processing
impact: MEDIUM
impactDescription: O(batch) memory vs O(n) for full dataset
tags: enum, batch, each-slice, memory
---

## Use each_slice for Batch Processing

Loading an entire dataset into memory before processing risks exhausting available RAM on large tables. `each_slice` breaks the collection into fixed-size batches, keeping only one batch in memory at a time and allowing the garbage collector to reclaim previous batches between iterations.

**Incorrect (loads all records then processes):**

```ruby
users = User.where(subscribed: true).to_a  # loads entire result set into memory

users.each do |user|
  NotificationMailer.weekly_digest(user).deliver_later
end

products = Product.all.to_a                 # millions of rows materialized at once
products.each do |product|
  SearchIndex.update(product)               # memory grows unbounded during processing
end
```

**Correct (processes in fixed-size batches):**

```ruby
User.where(subscribed: true).find_each(batch_size: 1000) do |user|
  NotificationMailer.weekly_digest(user).deliver_later
end

Product.all.find_in_batches(batch_size: 1000) do |batch|
  SearchIndex.bulk_update(batch)            # only 1000 records in memory at a time
end

# For non-ActiveRecord enumerables, use each_slice
large_csv_rows.each_slice(500) do |batch|
  ImportService.process(batch)
end
```
