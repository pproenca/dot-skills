---
title: Set Frozen String Literal as Project Default
impact: LOW-MEDIUM
impactDescription: reduces string allocations across entire codebase
tags: runtime, frozen, strings, configuration
---

## Set Frozen String Literal as Project Default

Every unadorned string literal in Ruby allocates a new object. Freezing string literals by default eliminates these redundant allocations project-wide, reducing GC pressure. Relying on per-file pragma comments is error-prone and inconsistent. See [Enable Frozen String Literals](str-frozen-literals.md) for per-file details and the `+""` escape hatch.

**Incorrect (relying on per-file pragma comments is inconsistent):**

```ruby
# Some files have the pragma, most don't
# app/services/order_service.rb
# frozen_string_literal: true  (easy to forget in new files)

class OrderService
  STATUS_PENDING = "pending"  # Frozen only if pragma present

  def status_label(order)
    "Order ##{order.id}: #{order.status}"  # New allocation every call
  end
end

# app/models/product.rb
# (no pragma — developer forgot)
class Product
  DEFAULT_CURRENCY = "USD"  # New object allocated every reference
end
```

**Correct (enforce frozen strings project-wide):**

```ruby
# .rubocop.yml — enforce the pragma on every file
Style/FrozenStringLiteralComment:
  Enabled: true
  EnforcedStyle: always

# Alternatively, set via Ruby flag in Procfile or Dockerfile
# ruby --enable-frozen-string-literal app.rb
# Or RUBYOPT="--enable-frozen-string-literal"

# app/services/order_service.rb
# frozen_string_literal: true

class OrderService
  STATUS_PENDING = "pending"  # Shared frozen instance

  def status_label(order)
    +"Order ##{order.id}: #{order.status}"  # Unary + for mutable when needed
  end
end
```
