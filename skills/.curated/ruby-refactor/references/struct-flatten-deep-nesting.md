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
    error = validate(payment)
    return error if error

    account = find_account(payment)
    return account unless account.is_a?(Account) # returns error hash if not found

    error = verify_account(account, payment)
    return error if error

    execute_payment(account, payment)
  end

  private

  def validate(payment)
    return { success: false, error: "Amount must be positive" } unless payment.amount > 0
    return { success: false, error: "Currency not supported" } unless payment.currency_supported?
    return { success: false, error: "Payment flagged for manual review" } if payment.flagged_for_review?

    nil # no error
  end

  def find_account(payment)
    account = Account.find_by(id: payment.account_id)
    account || { success: false, error: "Account not found" }
  end

  def verify_account(account, payment)
    return { success: false, error: "Account is suspended" } unless account.active?
    return { success: false, error: "Insufficient balance" } unless account.balance >= payment.amount

    nil
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
