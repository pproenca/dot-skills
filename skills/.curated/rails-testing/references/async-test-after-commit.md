---
title: Account for Transaction-Aware Job Enqueuing
impact: MEDIUM-HIGH
impactDescription: prevents 100% of missing job enqueues caused by transaction-aware callbacks
tags: async, after-commit, transactions, enqueue-after-transaction-commit, active-job
---

## Account for Transaction-Aware Job Enqueuing

Rails 5.0+ fires `after_commit` callbacks inside test transactions, so basic after_commit testing works out of the box. However, Rails 7.2 introduced `enqueue_after_transaction_commit` for Active Job, which defers job enqueuing until after the transaction commits. In tests using transactional fixtures, the transaction never commits — so jobs configured with this behavior appear to never enqueue. Understand which callback mechanism your code uses and test accordingly.

**Incorrect (expecting enqueued jobs inside an uncommitted test transaction with Rails 7.2+):**

```ruby
# app/jobs/fulfillment_sync_job.rb
class FulfillmentSyncJob < ApplicationJob
  self.enqueue_after_transaction_commit = true  # Rails 7.2+ default for some adapters

  def perform(order_id)
    Order.find(order_id).sync_to_fulfillment!
  end
end

# app/models/order.rb
class Order < ApplicationRecord
  after_create_commit :schedule_fulfillment

  private

  def schedule_fulfillment
    FulfillmentSyncJob.perform_later(id)
  end
end

# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  it "enqueues a fulfillment sync job" do
    # after_create_commit fires (Rails 5.0+), but the job uses
    # enqueue_after_transaction_commit — test transaction never commits
    expect { create(:order) }.to have_enqueued_job(FulfillmentSyncJob)
    # => FAILS: job deferred until transaction commit, which never happens
  end
end
```

**Correct (test the callback behavior directly, or disable transaction-aware enqueuing in tests):**

```ruby
# Option 1: Disable transaction-aware enqueuing in test environment
# config/environments/test.rb
Rails.application.configure do
  config.active_job.enqueue_after_transaction_commit = :never
end

# Now after_commit callbacks fire AND jobs enqueue immediately
RSpec.describe Order, type: :model do
  it "enqueues a fulfillment sync job after creation" do
    expect { create(:order) }.to have_enqueued_job(FulfillmentSyncJob)
  end
end

# Option 2: Test the callback's side effects directly
RSpec.describe Order, type: :model do
  it "calls schedule_fulfillment after commit" do
    order = build(:order)

    expect(order).to receive(:schedule_fulfillment)

    order.save!
    order.run_callbacks(:commit)
  end
end
```

**When to use each approach:**
- Use Option 1 for most test suites — simplest and most reliable
- Use Option 2 when you need to verify callback wiring specifically

Reference: [Rails 7.2 — enqueue_after_transaction_commit](https://guides.rubyonrails.org/active_job_basics.html#enqueue-after-transaction-commit) | [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html#testing)
