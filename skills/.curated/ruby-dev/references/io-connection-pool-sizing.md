---
title: Size Connection Pools to Match Thread Count
impact: MEDIUM
impactDescription: prevents connection checkout timeouts under load
tags: io, connection-pool, threads, database
---

## Size Connection Pools to Match Thread Count

When the database connection pool is smaller than the number of threads or workers competing for connections, threads block waiting for a checkout and eventually raise `ActiveRecord::ConnectionTimeoutError`. Set the pool size to at least match the maximum thread count of your application server.

**Incorrect (pool smaller than thread count, causes timeouts):**

```yaml
# config/database.yml
production:
  adapter: postgresql
  database: storefront_production
  pool: 5  # default, but Puma runs 5 threads per worker = contention under load
```

```ruby
# config/puma.rb
workers 2
threads 5, 5  # 5 threads per worker, 10 total — only 5 connections available per process
```

**Correct (pool sized to thread count):**

```yaml
# config/database.yml
production:
  adapter: postgresql
  database: storefront_production
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

```ruby
# config/puma.rb
max_threads = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
workers ENV.fetch("WEB_CONCURRENCY") { 2 }.to_i
threads max_threads, max_threads  # pool size matches thread count
```
