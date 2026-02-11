---
title: Replace Nested Conditionals with Guard Clauses
impact: CRITICAL
impactDescription: reduces nesting depth by 2-4 levels
tags: cond, guard-clause, early-return, nesting
---

## Replace Nested Conditionals with Guard Clauses

Deeply nested conditionals force readers to hold multiple branch contexts in working memory simultaneously. Each nesting level doubles the number of mental paths through the method. Guard clauses flatten the structure by handling exceptional cases first, leaving the happy path at the bottom with zero indentation.

**Incorrect (deeply nested validation):**

```ruby
class PaymentAuthorizer
  def authorize(payment)
    if payment.amount > 0
      if payment.card.present?
        if payment.card.balance >= payment.amount
          if !payment.flagged_for_fraud?
            payment.charge!  # happy path buried under 4 levels of nesting
            { success: true, transaction_id: payment.transaction_id }
          else
            { success: false, error: "payment flagged for fraud review" }
          end
        else
          { success: false, error: "insufficient balance" }
        end
      else
        { success: false, error: "no card on file" }
      end
    else
      { success: false, error: "invalid payment amount" }
    end
  end
end
```

**Correct (flat guard clauses with early returns):**

```ruby
class PaymentAuthorizer
  def authorize(payment)
    return { success: false, error: "invalid payment amount" } unless payment.amount > 0
    return { success: false, error: "no card on file" } unless payment.card.present?
    return { success: false, error: "insufficient balance" } unless payment.card.balance >= payment.amount
    return { success: false, error: "payment flagged for fraud review" } if payment.flagged_for_fraud?

    payment.charge!  # happy path at natural reading level
    { success: true, transaction_id: payment.transaction_id }
  end
end
```
