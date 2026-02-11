---
title: Reuse Buffers in Loops
impact: MEDIUM-HIGH
impactDescription: reduces allocations from O(n) to O(1)
tags: alloc, buffers, loops, reuse
---

## Reuse Buffers in Loops

Creating a new String or Array inside a loop allocates a fresh object per iteration. Declaring the buffer once outside the loop and clearing it with `.clear` or `.replace` reuses the same memory, dropping allocations from O(n) to O(1).

**Incorrect (allocates a new string per iteration):**

```ruby
class CsvExporter
  def generate(orders)
    output = +""
    orders.each do |order|
      line = +""  # New string allocated every iteration
      line << order.id.to_s
      line << ","
      line << order.customer_name
      line << ","
      line << format("%.2f", order.total)
      line << "\n"
      output << line
    end
    output
  end
end
```

**Correct (reuses a single buffer):**

```ruby
class CsvExporter
  def generate(orders)
    output = +""
    line = +""  # Single allocation, reused across iterations
    orders.each do |order|
      line.clear  # Resets length to 0, keeps allocated memory
      line << order.id.to_s
      line << ","
      line << order.customer_name
      line << ","
      line << format("%.2f", order.total)
      line << "\n"
      output << line
    end
    output
  end
end
```

**Same pattern with arrays:**

```ruby
# Incorrect -- allocates per batch
batches.each do |batch|
  ids = []  # New array per batch
  batch.each { |record| ids << record.id }
  process_ids(ids)
end

# Correct -- reuses buffer
ids = []
batches.each do |batch|
  ids.clear  # Resets without deallocating
  batch.each { |record| ids << record.id }
  process_ids(ids)
end
```
