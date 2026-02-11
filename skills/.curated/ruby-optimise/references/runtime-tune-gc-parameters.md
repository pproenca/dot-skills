---
title: Tune GC Parameters for Your Workload
impact: LOW-MEDIUM
impactDescription: reduces GC pause frequency by 30-50% for known allocation patterns
tags: runtime, gc, tuning, configuration
---

## Tune GC Parameters for Your Workload

Ruby's default GC settings are conservative, optimized for small scripts. Web applications with predictable allocation patterns benefit from pre-allocating heap slots and reducing growth frequency, cutting GC pauses that add latency to every request.

**Incorrect (default GC settings cause frequent pauses under load):**

```ruby
# No GC configuration — defaults apply
# Ruby starts with a small heap and grows incrementally
# Each request triggers multiple GC cycles as the heap
# expands to fit the application's actual memory needs
# Result: 50-100ms p99 spikes from major GC during traffic

# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY", 2)
threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
threads threads_count, threads_count
```

**Correct (tuned GC reduces pause frequency for web workloads):**

```ruby
# config/environments/production.rb or container ENV
# Pre-allocate heap slots per size pool (Ruby 3.3+)
ENV["RUBY_GC_HEAP_0_INIT_SLOTS"]       ||= "600000"
ENV["RUBY_GC_HEAP_1_INIT_SLOTS"]       ||= "100000"
ENV["RUBY_GC_HEAP_2_INIT_SLOTS"]       ||= "50000"
# Grow heap conservatively to avoid over-allocation
ENV["RUBY_GC_HEAP_GROWTH_FACTOR"]      ||= "1.1"
# Allow more allocations between GC runs
ENV["RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO"] ||= "0.20"
ENV["RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO"] ||= "0.40"
# Raise threshold before triggering major GC
ENV["RUBY_GC_MALLOC_LIMIT"]            ||= "64000000"
ENV["RUBY_GC_OLDMALLOC_LIMIT"]         ||= "64000000"

# Verify settings at boot
Rails.logger.info("GC stats: #{GC.stat.slice(:heap_available_slots, :major_gc_count)}")
```

**When NOT to use this pattern:**
- The per-size-pool variables (`RUBY_GC_HEAP_0_INIT_SLOTS`, etc.) require Ruby 3.3+; for Ruby 3.2 and earlier, use the legacy `RUBY_GC_HEAP_INIT_SLOTS`
- Profile with `GC.stat` under realistic load before choosing values — wrong parameters can increase memory without reducing pauses

Reference: [Practical Garbage Collection Tuning in Ruby (AppSignal)](https://blog.appsignal.com/2021/11/17/practical-garbage-collection-tuning-in-ruby.html)
