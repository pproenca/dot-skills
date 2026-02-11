---
title: Use case/in for Structural Pattern Matching
impact: MEDIUM
impactDescription: replaces 3-5 nested hash/array checks with one expression
tags: modern, pattern-matching, case-in, ruby3
---

## Use case/in for Structural Pattern Matching

Manually traversing nested hashes with chained `&&` guards is brittle and obscures the structure you actually expect. Each access adds a nil-check obligation and a potential `NoMethodError`. Ruby 3.0+ `case/in` pattern matching declaratively describes the expected shape, destructures values inline, and makes missing-key handling exhaustive.

**Incorrect (chained nil guards for nested hash access):**

```ruby
class ApiResponseParser
  def extract_user_email(response)
    if response[:data] && response[:data][:user] && response[:data][:user][:email]
      email = response[:data][:user][:email]  # 3 redundant traversals of the same path
      if response[:data][:user][:verified]
        { email: email, verified: true }
      else
        { email: email, verified: false }
      end
    elsif response[:error]
      { error: response[:error][:message] || "unknown error" }
    else
      { error: "malformed response" }
    end
  end
end
```

**Correct (pattern matching with destructuring):**

```ruby
class ApiResponseParser
  def extract_user_email(response)
    case response
    in { data: { user: { email:, verified: true } } }  # declares shape and destructures in one expression
      { email: email, verified: true }
    in { data: { user: { email: } } }
      { email: email, verified: false }
    in { error: { message: } }
      { error: message }
    else
      { error: "malformed response" }
    end
  end
end
```
