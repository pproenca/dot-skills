---
title: Size Thread Pools to Match Workload
impact: MEDIUM
impactDescription: prevents GVL contention and resource exhaustion
tags: conc, threads, pool, gvl
---

## Size Thread Pools to Match Workload

Unbounded thread creation causes memory bloat and excessive GVL contention. A fixed-size thread pool with a work queue keeps resource usage predictable and throughput stable under load.

**Incorrect (unbounded threads cause resource exhaustion):**

```ruby
class OrderExportService
  def export_all(orders)
    threads = orders.map do |order|
      Thread.new { generate_pdf(order) }  # 10,000 orders = 10,000 threads
    end

    threads.each do |t|
      t.join  # GVL thrashing kills throughput
    end
  end

  private

  def generate_pdf(order)
    # CPU-bound PDF generation competing for GVL
    PdfGenerator.new(order).render
  end
end
```

**Correct (fixed pool with queue prevents resource exhaustion):**

```ruby
class OrderExportService
  POOL_SIZE = Integer(ENV.fetch("EXPORT_THREADS", 5))

  def export_all(orders)
    queue = Queue.new
    orders.each { |order| queue << order }
    POOL_SIZE.times { queue << :done }

    workers = POOL_SIZE.times.map do
      Thread.new do
        while (order = queue.pop) != :done
          generate_pdf(order)
        end
      end
    end

    workers.each(&:join)  # Bounded concurrency, predictable memory
  end

  private

  def generate_pdf(order)
    PdfGenerator.new(order).render
  end
end
```
