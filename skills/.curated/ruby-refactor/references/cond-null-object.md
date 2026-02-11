---
title: Replace nil Checks with Null Object
impact: HIGH
impactDescription: eliminates N nil-guard conditionals per call site
tags: cond, null-object, nil, duck-typing
---

## Replace nil Checks with Null Object

Scattered nil checks for optional associations create a shotgun of defensive conditionals throughout the codebase. Every caller must remember to guard against nil, and forgetting one produces a NoMethodError in production. A Null Object that responds to the same interface as the real object removes all guards at once, leveraging Ruby's duck typing to make the absence of a value behave like a sensible default.

**Incorrect (nil guards scattered across call sites):**

```ruby
class AccountDashboard
  def display_plan(user)
    if user.subscription
      plan_name = user.subscription.plan
    else
      plan_name = "Free"
    end

    if user.subscription&.premium?
      show_premium_badge(user)
    end

    remaining = if user.subscription
      user.subscription.days_remaining  # every call site repeats the nil guard
    else
      0
    end

    render_dashboard(plan_name: plan_name, days_remaining: remaining)
  end
end
```

**Correct (Null Object with matching interface):**

```ruby
class NullSubscription
  def plan
    "Free"
  end

  def premium?
    false
  end

  def days_remaining
    0
  end

  def active?
    false
  end
end

class User
  def subscription
    super || NullSubscription.new  # single nil guard replaces all downstream checks
  end
end

class AccountDashboard
  def display_plan(user)
    plan_name = user.subscription.plan
    show_premium_badge(user) if user.subscription.premium?
    remaining = user.subscription.days_remaining  # no nil checks, same interface

    render_dashboard(plan_name: plan_name, days_remaining: remaining)
  end
end
```
