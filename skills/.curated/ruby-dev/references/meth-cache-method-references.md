---
title: Cache Method References for Repeated Calls
impact: MEDIUM-HIGH
impactDescription: avoids repeated method lookup and Proc allocation overhead
tags: meth, method, cache, lookup
---

## Cache Method References for Repeated Calls

Each call to `obj.method(:name)` allocates a new `Method` object and performs a method lookup. When passing the same method reference to `map`, `select`, or callbacks inside a loop, capture it once before iteration to eliminate repeated lookups and allocations.

**Incorrect (new Method object allocated on every iteration):**

```ruby
class OrderProcessor
  def format(order)
    "#{order.id}: #{order.total}"
  end
end

processor = OrderProcessor.new

batches.each do |batch|
  batch.map(&processor.method(:format))  # New Method + Proc allocated per batch
end
```

**Correct (single lookup, reused reference):**

```ruby
class OrderProcessor
  def format(order)
    "#{order.id}: #{order.total}"
  end
end

processor = OrderProcessor.new
formatter = processor.method(:format)  # One lookup, one allocation

batches.each do |batch|
  batch.map(&formatter)  # Reuses cached reference
end
```
