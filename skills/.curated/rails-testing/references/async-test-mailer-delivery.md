---
title: Test Mailer Delivery with deliver_later
impact: MEDIUM
impactDescription: mailers sent via deliver_later need Active Job testing setup
tags: async, mailer, deliver-later, active-job, email
---

## Test Mailer Delivery with deliver_later

When mailers use `deliver_later`, the email is enqueued as an Active Job rather than delivered synchronously. Use the `have_enqueued_mail` matcher to verify the mailer was enqueued with the correct arguments. Test the email's content (subject, body, recipients) in a dedicated mailer spec — not inside a request or system spec where the concern is whether the right mailer was triggered.

**Incorrect (testing full email content in a request spec):**

```ruby
# spec/requests/orders_spec.rb
RSpec.describe "POST /orders", type: :request do
  it "sends a confirmation email with the correct content" do
    user = create(:user)
    product = create(:product, name: "Ruby Debugger Pro")

    perform_enqueued_jobs do
      post orders_path,
        params: { order: { product_id: product.id, quantity: 1 } },
        headers: auth_headers_for(user)
    end

    # Request spec is now coupled to email template details
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to include(user.email)
    expect(mail.subject).to eq("Order Confirmation ##{Order.last.number}")
    expect(mail.body.encoded).to include("Ruby Debugger Pro")
    expect(mail.body.encoded).to include("$49.99")
  end
end
```

**Correct (request spec verifies enqueue, mailer spec verifies content):**

```ruby
# spec/requests/orders_spec.rb
RSpec.describe "POST /orders", type: :request do
  it "enqueues a confirmation email for the order" do
    user = create(:user)
    product = create(:product)

    expect {
      post orders_path,
        params: { order: { product_id: product.id, quantity: 1 } },
        headers: auth_headers_for(user)
    }.to have_enqueued_mail(OrderMailer, :confirmation).with(a_kind_of(Integer))
  end
end

# spec/mailers/order_mailer_spec.rb
RSpec.describe OrderMailer, type: :mailer do
  describe "#confirmation" do
    it "sends to the customer with order details" do
      order = create(:order, :with_items)
      mail = described_class.confirmation(order.id)

      expect(mail.to).to eq([order.user.email])
      expect(mail.subject).to eq("Order Confirmation ##{order.number}")
    end

    it "includes product names and total in the body" do
      order = create(:order, :with_items, total_cents: 4_999)
      mail = described_class.confirmation(order.id)

      expect(mail.body.encoded).to include(order.items.first.product.name)
      expect(mail.body.encoded).to include("$49.99")
    end
  end
end
```

**Note:** Use `ActionMailer::Base.deliveries` for synchronous `deliver_now` calls. For `deliver_later`, prefer the `have_enqueued_mail` matcher which inspects the Active Job queue without executing the job.

Reference: [Action Mailer Testing — Rails Guides](https://guides.rubyonrails.org/testing.html#testing-your-mailers) | [RSpec Rails — Mailer Matchers](https://rspec.info/features/6-1/rspec-rails/matchers/have-enqueued-mail-matcher/)
