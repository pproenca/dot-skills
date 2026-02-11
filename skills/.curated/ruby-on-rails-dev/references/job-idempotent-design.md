---
title: Design Jobs to Be Idempotent
impact: LOW-MEDIUM
impactDescription: prevents duplicate processing on retries
tags: job, idempotency, reliability, retries
---

## Design Jobs to Be Idempotent

Jobs will be retried on failure. If a job charges a credit card or sends an email without idempotency checks, retries cause duplicate charges or emails.

**Incorrect (non-idempotent, duplicates on retry):**

```ruby
class ChargeOrderJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    PaymentGateway.charge(order.user.payment_method, order.total)  # Charges again on retry
    OrderMailer.receipt(order).deliver_now  # Sends duplicate email on retry
  end
end
```

**Correct (idempotent with guard checks):**

```ruby
class ChargeOrderJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)
    return if order.charged?

    PaymentGateway.charge(order.user.payment_method, order.total)
    order.update!(charged_at: Time.current)
    OrderMailer.receipt(order).deliver_now
  end
end
```

**Benefits:**
- Safe to retry any number of times
- Database state tracks completion
- No duplicate side effects

Reference: [Active Job Basics — Rails Guides](https://guides.rubyonrails.org/active_job_basics.html)
