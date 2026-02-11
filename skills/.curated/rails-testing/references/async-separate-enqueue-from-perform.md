---
title: Separate Enqueue Tests from Perform Tests
impact: MEDIUM
impactDescription: prevents brittle integration between controller and job logic
tags: async, enqueue, perform, separation, active-job, sidekiq
---

## Separate Enqueue Tests from Perform Tests

Test that the controller or service enqueues the right job with the right arguments (using fake/test mode). Test that the job's `perform` method produces the correct side effects in a separate spec. Combining both in one test creates a fragile coupling — a change to job internals breaks controller specs, and a change to enqueue arguments breaks job specs.

**Incorrect (testing job execution inside a request spec):**

```ruby
# spec/requests/orders_spec.rb
RSpec.describe "POST /orders", type: :request do
  it "creates an order and sends the confirmation email" do
    user = create(:user, :with_payment_method)
    product = create(:product, stock: 5)

    # This test does too much: it verifies the request, the job, AND the mailer
    perform_enqueued_jobs do
      post orders_path, params: {
        order: { product_id: product.id, quantity: 2 }
      }, headers: auth_headers_for(user)
    end

    expect(response).to have_http_status(:created)
    expect(product.reload.stock).to eq(3)
    expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    expect(ActionMailer::Base.deliveries.last.subject).to include("Order Confirmation")
  end
end
```

**Correct (request spec tests enqueue, job spec tests execution):**

```ruby
# spec/requests/orders_spec.rb
RSpec.describe "POST /orders", type: :request do
  it "creates an order and enqueues a confirmation job" do
    user = create(:user, :with_payment_method)
    product = create(:product, stock: 5)

    expect {
      post orders_path, params: {
        order: { product_id: product.id, quantity: 2 }
      }, headers: auth_headers_for(user)
    }.to have_enqueued_job(OrderConfirmationJob).with(Order.last.id)

    expect(response).to have_http_status(:created)
  end
end

# spec/jobs/order_confirmation_job_spec.rb
RSpec.describe OrderConfirmationJob, type: :job do
  describe "#perform" do
    it "sends a confirmation email with order details" do
      order = create(:order, :with_items)

      expect {
        described_class.perform_now(order.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(order.user.email)
      expect(mail.subject).to include("Order ##{order.number}")
    end

    it "skips sending if the order has already been confirmed" do
      order = create(:order, :confirmed)

      expect {
        described_class.perform_now(order.id)
      }.not_to change { ActionMailer::Base.deliveries.count }
    end
  end
end
```

Reference: [Active Job Testing — Rails Guides](https://guides.rubyonrails.org/testing.html#testing-jobs) | [Better Specs](https://www.betterspecs.org/)
