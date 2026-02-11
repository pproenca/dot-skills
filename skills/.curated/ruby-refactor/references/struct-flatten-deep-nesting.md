---
title: Flatten Deep Nesting with Early Extraction
impact: HIGH
impactDescription: reduces cyclomatic complexity by 40-60%
tags: struct, nesting, complexity, extract-method
---

## Flatten Deep Nesting with Early Extraction

Each level of nesting doubles the mental effort required to trace execution paths. Deeply nested code obscures the happy path and makes edge cases invisible. Extract nested blocks into named methods with early returns so each method handles one concern at one level.

**Incorrect (4+ levels of nesting in payment processing):**

```ruby
class PaymentProcessor
  def process(payment)
    if payment.amount > 0
      if payment.currency_supported?
        account = Account.find_by(id: payment.account_id)
        if account
          if account.active?
            if account.balance >= payment.amount
              if !payment.flagged_for_review?
                transaction = account.debit(payment.amount)
                receipt = Receipt.create!(transaction: transaction, payment: payment)
                NotificationService.send_confirmation(account.owner, receipt)
                { success: true, receipt_id: receipt.id }
              else
                { success: false, error: "Payment flagged for manual review" }
              end
            else
              { success: false, error: "Insufficient balance" }
            end
          else
            { success: false, error: "Account is suspended" }
          end
        else
          { success: false, error: "Account not found" }
        end
      else
        { success: false, error: "Currency not supported" }
      end
    else
      { success: false, error: "Amount must be positive" }
    end
  end
end
```

**Correct (flat methods with early returns):**

```ruby
class PaymentProcessor
  def process(payment)
    validate(payment)
    account = find_account(payment)
    verify_account(account, payment)
    execute_payment(account, payment)
  end

  private

  def validate(payment)
    raise PaymentError, "Amount must be positive" unless payment.amount > 0
    raise PaymentError, "Currency not supported" unless payment.currency_supported?
    raise PaymentError, "Payment flagged for manual review" if payment.flagged_for_review?
  end

  def find_account(payment)
    Account.find_by(id: payment.account_id) ||
      raise(PaymentError, "Account not found")
  end

  def verify_account(account, payment)
    raise PaymentError, "Account is suspended" unless account.active?
    raise PaymentError, "Insufficient balance" unless account.balance >= payment.amount
  end

  def execute_payment(account, payment)
    transaction = account.debit(payment.amount)
    receipt = Receipt.create!(transaction: transaction, payment: payment)
    NotificationService.send_confirmation(account.owner, receipt)
    { success: true, receipt_id: receipt.id }
  end
end
```

Reference: [Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)
