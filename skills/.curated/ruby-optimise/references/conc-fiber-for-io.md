---
title: Use Fibers for I/O-Bound Concurrency
impact: MEDIUM
impactDescription: reduces memory 250x per concurrent task (~4KB vs ~1MB)
tags: conc, fiber, io, async
---

## Use Fibers for I/O-Bound Concurrency

Fibers provide cooperative concurrency with minimal memory overhead, making them ideal for I/O-bound workloads like HTTP requests, database queries, and file operations. Spawning OS threads for each concurrent I/O task wastes memory and hits OS limits quickly.

**Incorrect (one thread per HTTP request exhausts resources):**

```ruby
require "net/http"

def fetch_product_prices(product_urls)
  threads = product_urls.map do |url|
    Thread.new do  # ~1MB stack per thread, OS limit ~1024 threads
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      JSON.parse(response.body)
    end
  end

  threads.map(&:value)  # Blocks until all complete
rescue ThreadError => e
  # "can't create Thread: Resource temporarily unavailable"
  Rails.logger.error("Thread pool exhausted: #{e.message}")
  []
end
```

**Correct (fibers handle thousands of concurrent I/O operations):**

```ruby
require "async"
require "async/http/internet"

def fetch_product_prices(product_urls)
  Async do
    internet = Async::HTTP::Internet.new
    barrier = Async::Barrier.new

    results = product_urls.map do |url|
      barrier.async do  # ~4KB per fiber, scales to thousands
        response = internet.get(url)
        JSON.parse(response.read)
      end
    end

    barrier.wait
    results.map(&:wait)
  ensure
    internet&.close
  end
end
```
