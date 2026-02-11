---
title: Prevent Duplicate Job Enqueuing
impact: LOW-MEDIUM
impactDescription: eliminates redundant work from rapid-fire triggers
tags: job, deduplication, unique-jobs, throttling
---

## Prevent Duplicate Job Enqueuing

Rapid user actions or webhook retries enqueue the same job multiple times. Use unique job locks to deduplicate.

**Incorrect (duplicate jobs enqueued):**

```ruby
class SyncInventoryJob < ApplicationJob
  def perform(product_id)
    product = Product.find(product_id)
    InventoryService.sync(product)  # 10 webhook hits = 10 identical syncs
  end
end

# Webhook handler
product.webhooks.each do |webhook|
  SyncInventoryJob.perform_later(product.id)  # Enqueues multiple times
end
```

**Correct (unique job with lock):**

```ruby
# Using SolidQueue (Rails 8+) or sidekiq-unique-jobs
class SyncInventoryJob < ApplicationJob
  self.queue_adapter = :solid_queue
  limits_concurrency to: 1, key: ->(product_id) { "sync_inventory_#{product_id}" }

  def perform(product_id)
    product = Product.find(product_id)
    InventoryService.sync(product)
  end
end
```

**Alternative (manual deduplication):**

```ruby
class SyncInventoryJob < ApplicationJob
  def perform(product_id)
    lock_key = "sync_inventory_#{product_id}"
    return if Rails.cache.exist?(lock_key)

    Rails.cache.write(lock_key, true, expires_in: 5.minutes)
    product = Product.find(product_id)
    InventoryService.sync(product)
  end
end
```

Reference: [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html)
