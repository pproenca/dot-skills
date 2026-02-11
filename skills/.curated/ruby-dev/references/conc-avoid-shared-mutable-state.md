---
title: Avoid Shared Mutable State Between Threads
impact: MEDIUM
impactDescription: prevents race conditions and eliminates mutex contention overhead
tags: conc, threads, mutex, thread-safety
---

## Avoid Shared Mutable State Between Threads

Sharing mutable data between threads requires Mutex locks that serialize access, destroying concurrency benefits. Thread-local accumulators merged at the end eliminate contention while preserving correctness.

**Incorrect (shared counter with Mutex creates serialized bottleneck):**

```ruby
class InventoryAuditor
  def count_items_by_category(products)
    totals = Hash.new(0)
    mutex = Mutex.new

    workers = products.each_slice(100).map do |batch|
      Thread.new do
        batch.each do |product|
          mutex.synchronize do  # Every increment waits for the lock
            totals[product.category] += 1
          end
        end
      end
    end

    workers.each(&:join)
    totals  # Threads spent more time waiting than working
  end
end
```

**Correct (thread-local accumulators merged at end):**

```ruby
class InventoryAuditor
  def count_items_by_category(products)
    workers = products.each_slice(100).map do |batch|
      Thread.new do
        local_totals = Hash.new(0)  # No sharing, no locks needed
        batch.each do |product|
          local_totals[product.category] += 1
        end
        local_totals
      end
    end

    workers
      .map(&:value)
      .each_with_object(Hash.new(0)) do |local, merged|
        local.each { |category, count| merged[category] += count }
      end
  end
end
```
