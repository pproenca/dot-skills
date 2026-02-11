---
title: Avoid Dynamic send in Performance-Critical Code
impact: MEDIUM
impactDescription: send bypasses visibility checks and prevents YJIT optimization
tags: meth, send, dynamic, dispatch
---

## Avoid Dynamic send in Performance-Critical Code

`send` and `public_send` resolve method names at runtime, which bypasses the inline method cache and prevents YJIT from compiling an optimized dispatch. In tight loops this means each call pays the full lookup cost instead of hitting a cached path.

**Incorrect (dynamic dispatch defeats inline caching):**

```ruby
class OrderExporter
  def to_csv(order)
    order.values.join(",")
  end

  def to_json(order)
    order.to_h.to_json
  end

  def export_all(orders, format)
    method_name = "to_#{format}"
    orders.map do |order|
      send(method_name, order)  # Runtime lookup on every iteration
    end
  end
end
```

**Correct (static dispatch, YJIT-optimizable):**

```ruby
class OrderExporter
  def to_csv(order)
    order.values.join(",")
  end

  def to_json(order)
    order.to_h.to_json
  end

  def export_all(orders, format)
    case format
    when :csv
      orders.map { |order| to_csv(order) }   # Direct dispatch, cacheable
    when :json
      orders.map { |order| to_json(order) }  # Direct dispatch, cacheable
    else
      raise ArgumentError, "unsupported format: #{format}"
    end
  end
end
```

**When `send` is acceptable:**
- Metaprogramming frameworks (ORMs, serializers) where dynamism is the point
- One-off calls outside hot paths
- Test helpers accessing private methods
