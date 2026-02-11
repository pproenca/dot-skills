---
title: Use Pattern Matching with Guard Clauses
impact: MEDIUM
impactDescription: reduces nested if/case from 3-4 levels to 1 flat match
tags: modern, pattern-matching, guard, case-in
---

## Use Pattern Matching with Guard Clauses

Nested `if`/`case` combinations that check both response structure and conditional values scatter related logic across multiple indentation levels. Ruby 3.0+ pattern matching supports `if` guards directly on `in` branches, combining structural matching and conditional logic into a single readable construct.

**Incorrect (nested if/case for status and body handling):**

```ruby
class HttpResponseHandler
  def process(response)
    if response[:status]
      status = response[:status]
      body = response[:body]
      if status >= 200 && status < 300
        if body && body[:items] && body[:items].size > 0  # structure check tangled with status logic
          { result: :success, items: body[:items] }
        else
          { result: :empty }
        end
      elsif status >= 400 && status < 500
        if body && body[:error]
          { result: :client_error, message: body[:error][:message] }
        else
          { result: :client_error, message: "unknown client error" }
        end
      elsif status >= 500
        { result: :server_error, retry: true }
      else
        { result: :unexpected, status: status }
      end
    else
      { result: :invalid_response }
    end
  end
end
```

**Correct (pattern matching with guard clauses):**

```ruby
class HttpResponseHandler
  def process(response)
    case response
    in { status: (200..299), body: { items: [_, *] => items } }  # structural match with array pattern
      { result: :success, items: items }
    in { status: (200..299) }
      { result: :empty }
    in { status: (400..499), body: { error: { message: } } }
      { result: :client_error, message: message }
    in { status: (400..499) }
      { result: :client_error, message: "unknown client error" }
    in { status: Integer => status } if status >= 500  # guard clause for open-ended range
      { result: :server_error, retry: true }
    else
      { result: :invalid_response }
    end
  end
end
```
