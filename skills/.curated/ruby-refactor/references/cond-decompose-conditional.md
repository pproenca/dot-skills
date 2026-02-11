---
title: Extract Complex Booleans into Named Predicates
impact: CRITICAL
impactDescription: reduces boolean complexity from N clauses to 1 named predicate
tags: cond, decompose, predicate, readability
---

## Extract Complex Booleans into Named Predicates

Compound boolean expressions encode business rules that are invisible to future readers. When the same multi-clause condition appears in two places, it will inevitably diverge. Extracting predicates names the business concept once, makes the condition testable in isolation, and turns the calling code into a readable sentence.

**Incorrect (inline compound boolean):**

```ruby
class PurchaseService
  def attempt_purchase(user, item)
    if user.age >= 18 && user.verified? && !user.suspended? && user.subscription.active?  # what business rule is this?
      charge_user(user, item)
    else
      deny_purchase(user, item)
    end
  end

  def show_premium_catalog(user)
    if user.age >= 18 && user.verified? && !user.suspended? && user.subscription.active?  # duplicated, will diverge
      render_catalog(user)
    end
  end
end
```

**Correct (named predicate methods):**

```ruby
class PurchaseService
  def attempt_purchase(user, item)
    if eligible_for_purchase?(user)  # reads as a business rule
      charge_user(user, item)
    else
      deny_purchase(user, item)
    end
  end

  def show_premium_catalog(user)
    render_catalog(user) if eligible_for_purchase?(user)
  end

  private

  def eligible_for_purchase?(user)
    of_legal_age?(user) && verified_and_active?(user)
  end

  def of_legal_age?(user)
    user.age >= 18
  end

  def verified_and_active?(user)
    user.verified? && !user.suspended? && user.subscription.active?
  end
end
```
