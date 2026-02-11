---
title: Enable Frozen String Literals
impact: HIGH
impactDescription: reduces GC pressure by ~20%, saves ~100MB in production Rails apps
tags: str, frozen, literals, gc
---

## Enable Frozen String Literals

Every string literal in Ruby allocates a new mutable object by default. In a request-heavy Rails app, this produces millions of short-lived strings that flood the garbage collector. The `frozen_string_literal` pragma makes every literal in the file frozen and deduplicated at compile time, eliminating those allocations entirely.

**Incorrect (new string allocated on every call):**

```ruby
class OrderMailer
  def confirmation_subject(order)
    prefix = "Order Confirmation"            # new String allocated each invocation
    separator = " - "                        # another allocation
    prefix + separator + order.reference     # yet another for the concatenation result
  end

  def format_status(order)
    status = "pending"                       # new "pending" every time, even though it never changes
    order.status == status ? "awaiting" : order.status
  end
end
```

**Correct (literals frozen and deduplicated at compile time):**

```ruby
# frozen_string_literal: true

class OrderMailer
  def confirmation_subject(order)
    prefix = "Order Confirmation"
    separator = " - "
    "#{prefix}#{separator}#{order.reference}"
  end

  def format_status(order)
    status = "pending"
    order.status == status ? "awaiting" : order.status
  end
end
```

See also: [Set Frozen String Literal as Project Default](runtime-frozen-string-literal-default.md) for enforcing this pragma across an entire codebase.

**When you need a mutable string in a frozen file:**

```ruby
# frozen_string_literal: true

def build_csv_row(product)
  row = +""                     # unary + creates a mutable copy
  row << product.name
  row << ","
  row << product.price.to_s
  row
end
```
