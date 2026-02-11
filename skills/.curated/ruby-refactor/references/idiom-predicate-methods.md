---
title: Name Boolean Methods with ? Suffix
impact: MEDIUM-HIGH
impactDescription: eliminates N return-type lookups per code review
tags: idiom, predicate, naming, convention
---

## Name Boolean Methods with ? Suffix

Ruby convention uses the `?` suffix to signal that a method returns a boolean. Prefixes like `is_` or `has_` are Java/Python idioms that add noise in Ruby. The `?` suffix is understood by every Ruby developer and reads naturally in conditionals: `if user.active?` reads as a question.

**Incorrect (Java-style boolean prefixes):**

```ruby
class Subscription
  def is_active
    expires_at > Time.current
  end

  def has_payment_method
    payment_methods.any?
  end

  def is_eligible_for_renewal
    is_active && has_payment_method && !is_cancelled
  end

  def is_cancelled
    cancelled_at.present?
  end
end

# reads awkwardly in conditionals
send_reminder(subscription) if subscription.is_eligible_for_renewal
```

**Correct (Ruby ? suffix convention):**

```ruby
class Subscription
  def active?
    expires_at > Time.current
  end

  def payment_method?  # no has_ prefix needed
    payment_methods.any?
  end

  def eligible_for_renewal?
    active? && payment_method? && !cancelled?
  end

  def cancelled?
    cancelled_at.present?
  end
end

# reads as natural English question
send_reminder(subscription) if subscription.eligible_for_renewal?
```
