---
title: Rename to Eliminate Need for Comments
impact: LOW-MEDIUM
impactDescription: self-documenting code outlives stale comments
tags: name, comments, self-documenting, rename
---

## Rename to Eliminate Need for Comments

A comment explaining what a method or variable does is a naming failure. Comments drift from reality as code evolves, but names are checked by every caller. When you feel the urge to write a comment, rename instead. A name that renders its comment redundant is always the better choice.

**Incorrect (comments compensate for vague names):**

```ruby
class Account
  # Check if user can access premium features
  def check(u)
    u.plan == :premium && u.status == :active
  end

  # Get the number of days left until the trial expires
  def remaining(user)
    (user.trial_end_date - Date.today).to_i
  end

  # Send email if invoice is more than 30 days overdue
  def process(invoice)
    if (Date.today - invoice.due_date).to_i > 30
      InvoiceMailer.overdue_notice(invoice).deliver_later
    end
  end
end
```

**Correct (names replace every comment):**

```ruby
class Account
  def user_has_premium_access?(user)
    user.plan == :premium && user.status == :active
  end

  def trial_days_remaining(user)  # name states exactly what is returned
    (user.trial_end_date - Date.today).to_i
  end

  def send_overdue_notice_if_past_threshold(invoice)
    if (Date.today - invoice.due_date).to_i > 30
      InvoiceMailer.overdue_notice(invoice).deliver_later
    end
  end
end
```
