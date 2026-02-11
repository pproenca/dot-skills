---
title: Use Intention-Revealing Names
impact: LOW-MEDIUM
impactDescription: eliminates need for explanatory comments
tags: name, intention, readability, self-documenting
---

## Use Intention-Revealing Names

Names should answer why something exists, what it does, and how it is used. When a variable or method name requires a comment to explain its purpose, the name has failed. Intention-revealing names make code read like prose and let reviewers focus on logic instead of deciphering abbreviations.

**Incorrect (cryptic names require mental translation):**

```ruby
class SubscriptionService
  def process(d)
    # d is the cutoff date for expiring trials
    u_list = User.where("cd < ?", d)
    u_list.each do |u|
      d2 = Date.today - u.cd  # days since creation
      if d2 > 14
        u.s.update!(status: :expired)
        n = Notification.new(u, :trial_ended)
        n.send
      end
    end
  end

  def calc(o)
    t = o.items.sum { |i| i.p * i.q }
    t - (t * o.dr)
  end
end
```

**Correct (names reveal intent without comments):**

```ruby
class SubscriptionService
  def expire_trial_subscriptions(cutoff_date)
    users = User.where("created_at < ?", cutoff_date)
    users.each do |user|
      days_since_creation = Date.today - user.created_at
      if days_since_creation > 14
        user.subscription.update!(status: :expired)
        notification = Notification.new(user, :trial_ended)
        notification.send
      end
    end
  end

  def calculate_discounted_total(order)
    total = order.items.sum { |item| item.price * item.quantity }
    total - (total * order.discount_rate)  # name makes formula self-evident
  end
end
```
