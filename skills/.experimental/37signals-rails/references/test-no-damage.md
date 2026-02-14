---
title: No Test-Induced Design Damage
impact: MEDIUM
impactDescription: prevents architectural compromises made purely for testability
tags: test, design-damage, dhh, testing-philosophy
---

## No Test-Induced Design Damage

Never modify application code solely to make testing easier. DHH coined the term "test-induced design damage" to describe architectural compromises — injected dependencies, extracted interfaces, hexagonal layers — introduced purely so unit tests can swap in mocks. These abstractions add indirection and complexity to production code that serves no user. Instead, write integration tests against the real system or use targeted stubs at the boundary. The design should serve the application's needs, not the test harness.

**Incorrect (production code warped for testability):**

```ruby
# app/models/order.rb — injected dependencies purely for test mocking
class Order < ApplicationRecord
  def complete(payment_gateway: StripeGateway.new, notifier: OrderNotifier.new, analytics: AnalyticsTracker.new)
    transaction do
      update!(status: "completed", completed_at: Time.current)
      payment_gateway.capture(payment_intent_id)
      notifier.order_completed(self)
      analytics.track("order_completed", order_id: id)
    end
  end
end

# test/models/order_test.rb — everything is mocked, tests prove nothing
class OrderTest < ActiveSupport::TestCase
  test "complete captures payment and notifies" do
    order = orders(:pending)
    gateway = Minitest::Mock.new
    notifier = Minitest::Mock.new
    analytics = Minitest::Mock.new

    gateway.expect :capture, true, [order.payment_intent_id]
    notifier.expect :order_completed, true, [order]
    analytics.expect :track, true, ["order_completed", { order_id: order.id }]

    order.complete(payment_gateway: gateway, notifier: notifier, analytics: analytics)

    gateway.verify
    notifier.verify
    analytics.verify
  end
end
```

**Correct (clean production code tested via integration test):**

```ruby
# app/models/order.rb — direct implementation, no injected seams
class Order < ApplicationRecord
  has_many :line_items
  belongs_to :customer

  after_update_commit :notify_completion, if: :saved_change_to_status?

  def complete
    transaction do
      update!(status: "completed", completed_at: Time.current)
      Stripe::PaymentIntent.capture(payment_intent_id)
    end
  end

  private

  def notify_completion
    OrderMailer.completed(self).deliver_later if status == "completed"
  end
end

# test/integration/checkout_test.rb — tests real user flow
class CheckoutTest < ActionDispatch::IntegrationTest
  test "completing an order captures payment and sends confirmation" do
    order = orders(:pending)
    sign_in order.customer

    stub_request(:post, %r{api.stripe.com/v1/payment_intents/.*/capture})
      .to_return(status: 200, body: { status: "succeeded" }.to_json)

    assert_enqueued_email_with OrderMailer, :completed, args: [order] do
      post complete_order_path(order)
    end

    assert_redirected_to order_path(order)
    assert order.reload.completed?
  end
end
```

**When NOT to use:**
- Dependency injection for genuinely swappable infrastructure (e.g., switching between S3 and GCS storage backends) is legitimate design — that serves production needs, not just testing.

Reference: [On Writing Software Well](https://signalvnoise.com/svn3/on-writing-software-well/)
