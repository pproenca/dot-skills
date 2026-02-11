---
title: Pass IDs to Jobs, Not Serialized Objects
impact: LOW-MEDIUM
impactDescription: avoids DeserializationError and reduces queue payload size
tags: job, serialization, payload, globalid
---

## Pass IDs to Jobs, Not Serialized Objects

ActiveRecord objects serialized via GlobalID are re-fetched by ID when the job executes. If the record is deleted between enqueue and execution, Rails raises `ActiveJob::DeserializationError`. Pass plain IDs for resilient job design.

**Incorrect (raises DeserializationError if record deleted):**

```ruby
class SendReceiptJob < ApplicationJob
  def perform(order)
    # If order is deleted before job runs, raises DeserializationError
    OrderMailer.receipt(order).deliver_now
  end
end

# Enqueue
SendReceiptJob.perform_later(Order.find(42))
```

**Correct (handles missing records gracefully):**

```ruby
class SendReceiptJob < ApplicationJob
  def perform(order_id)
    order = Order.find_by(id: order_id)
    return unless order  # Gracefully skip if deleted

    OrderMailer.receipt(order).deliver_now
  end
end

# Enqueue
SendReceiptJob.perform_later(42)
```

**When NOT to use this pattern:**
- When you want ActiveJob to automatically retry on DeserializationError (GlobalID is fine)
- For simple jobs where the record will always exist at execution time

Reference: [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html#globalid)
