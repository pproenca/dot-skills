---
title: Account for after_commit in Test Transactions
impact: MEDIUM-HIGH
impactDescription: after_commit callbacks silently skip inside test transactions by default
tags: async, after-commit, transactions, callbacks, active-record
---

## Account for after_commit in Test Transactions

By default, RSpec wraps each test in a database transaction that rolls back at the end. Because the transaction never commits, `after_commit` and `after_create_commit` callbacks never fire — jobs that are enqueued in these callbacks silently skip, webhook notifications never trigger, and cache invalidations never run. Rails 7.2+ fires `after_commit` callbacks within test transactions by default. For older Rails versions, use the `test_after_commit` gem or call `run_callbacks(:commit)` explicitly.

**Incorrect (after_commit callback silently never fires):**

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  after_commit :sync_to_fulfillment, on: :create

  private

  def sync_to_fulfillment
    FulfillmentSyncJob.perform_later(id)
  end
end

# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  describe "after creation" do
    it "enqueues a fulfillment sync job" do
      # This test PASSES incorrectly — no job was enqueued because
      # the transaction never committed, but the expectation doesn't catch it
      order = create(:order)

      # This assertion silently passes because have_enqueued_job checks an
      # empty queue and finds nothing — but the developer expected the callback to fire
      expect(FulfillmentSyncJob).to have_been_enqueued.with(order.id)
      # => FAILS, but the developer doesn't understand why
    end
  end
end
```

**Correct (ensure after_commit fires in tests):**

```ruby
# Option 1: Rails 7.2+ (built-in support, no gem needed)
# config/environments/test.rb
Rails.application.configure do
  # Rails 7.2+ fires after_commit callbacks inside test transactions by default
  # No additional configuration needed
end

# Option 2: Older Rails — use test_after_commit gem
# Gemfile
# gem "test_after_commit", group: :test

# Option 3: Explicitly trigger commit callbacks when testing specific behavior
# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  describe "after creation" do
    it "enqueues a fulfillment sync job" do
      order = create(:order)

      # Explicitly fire commit callbacks for older Rails versions
      order.run_callbacks(:commit)

      expect(FulfillmentSyncJob).to have_been_enqueued.with(order.id)
    end
  end
end

# Best approach (Rails 7.2+): callbacks fire automatically
RSpec.describe Order, type: :model do
  describe "after creation" do
    it "enqueues a fulfillment sync job" do
      expect {
        create(:order)
      }.to have_enqueued_job(FulfillmentSyncJob)
    end

    it "enqueues a webhook notification for the merchant" do
      merchant = create(:merchant, webhook_url: "https://api.example.com/orders")

      expect {
        create(:order, merchant: merchant)
      }.to have_enqueued_job(WebhookDeliveryJob).with(
        "order.created",
        merchant.webhook_url,
        a_kind_of(Integer)
      )
    end
  end
end
```

Reference: [Rails 7.2 Release Notes — Test Transaction Callbacks](https://guides.rubyonrails.org/7_2_release_notes.html) | [test_after_commit — GitHub](https://github.com/grosser/test_after_commit)
