---
title: Avoid Repeated Computation in Hot Paths
impact: MEDIUM-HIGH
impactDescription: eliminates redundant allocations from repeated to_s, to_a, Time.now
tags: alloc, conversions, implicit, performance
---

## Avoid Repeated Computation in Hot Paths

Expressions like `Time.now.to_s`, `Integer#to_s`, and `group.members.to_a` allocate new objects on every invocation. Inside tight loops, these repeated computations accumulate thousands of throwaway objects. Hoist invariant conversions outside the loop and pass raw values to helpers that format once.

**Incorrect (repeated conversions inside loop):**

```ruby
class InventoryReport
  def generate(products)
    rows = []
    products.each do |product|
      rows << "#{product.sku}: #{product.quantity} units @ #{product.price}"
      log_entry = {
        sku: product.sku.to_s,          # Allocates new string if sku is a Symbol
        quantity: product.quantity.to_s, # Integer#to_s allocates every call
        timestamp: Time.now.to_s        # New Time + new String per iteration
      }
      audit_log(log_entry)
    end
    rows
  end
end
```

**Correct (hoist invariant conversions, pass raw values):**

```ruby
class InventoryReport
  def generate(products)
    rows = []
    timestamp = Time.now.to_s  # Compute once — same timestamp for the batch
    products.each do |product|
      sku = product.sku
      qty = product.quantity
      price = product.price
      rows << "#{sku}: #{qty} units @ #{price}"
      audit_log(sku, qty, timestamp)  # Pass raw values, let the logger format once
    end
    rows
  end

  private

  def audit_log(sku, quantity, timestamp)
    @logger.write(sku, quantity, timestamp)
  end
end
```

**Pre-convert collections when shape is known:**

```ruby
# Incorrect -- to_a inside loop re-creates array each time
user_groups.each do |group|
  members = group.members.to_a  # New array per group even if already an Array
  process_members(members)
end

# Correct -- only convert if needed
user_groups.each do |group|
  members = group.members
  members = members.to_a unless members.is_a?(Array)
  process_members(members)
end
```
