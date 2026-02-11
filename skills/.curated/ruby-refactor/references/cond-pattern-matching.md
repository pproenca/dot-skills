---
title: Use Pattern Matching for Structural Conditions
impact: HIGH
impactDescription: replaces 3-5 nested hash/array checks with one expression
tags: cond, pattern-matching, ruby3, destructuring
---

## Use Pattern Matching for Structural Conditions

Deeply nested hash access with manual nil checks is fragile and hard to read. Each level of `response[:key] && response[:key][:nested]` adds a potential failure point and obscures the structure being validated. Ruby 3.x pattern matching (`case/in`) declaratively describes the expected shape and destructures values in a single expression, making structural expectations explicit and self-documenting.

**Incorrect (nested hash checks with manual nil guards):**

```ruby
class PaymentResponseParser
  def extract_transaction(response)
    if response[:data]
      if response[:data][:transaction]
        txn = response[:data][:transaction]
        if txn[:id] && txn[:status] == "completed" && txn[:amount]
          if txn[:amount][:value] && txn[:amount][:currency]  # 4 levels deep, easy to miss a nil check
            build_record(
              id: txn[:id],
              value: txn[:amount][:value],
              currency: txn[:amount][:currency]
            )
          else
            handle_malformed_response(response)
          end
        else
          handle_incomplete_transaction(response)
        end
      else
        handle_missing_transaction(response)
      end
    else
      handle_empty_response(response)
    end
  end
end
```

**Correct (pattern matching with destructuring):**

```ruby
class PaymentResponseParser
  def extract_transaction(response)
    case response
    in { data: { transaction: { id:, status: "completed",
          amount: { value:, currency: } } } }  # declares expected shape in one expression
      build_record(id: id, value: value, currency: currency)
    in { data: { transaction: { id:, status: } } }
      handle_incomplete_transaction(response)
    in { data: { transaction: nil } }
      handle_missing_transaction(response)
    else
      handle_empty_response(response)
    end
  end
end
```
