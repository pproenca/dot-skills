---
title: Use Database-Backed Infrastructure Over Redis
impact: HIGH
impactDescription: eliminates Redis and external state dependencies, simplifies infrastructure
tags: db, database, infrastructure, solid
---

## Use Database-Backed Infrastructure Over Redis

All persistent state lives in PostgreSQL or SQLite. 37signals replaced Redis with database-backed alternatives — Solid Queue for jobs, Solid Cable for pub/sub, Solid Cache for caching — collapsing the infrastructure stack to a single data store. One fewer process to monitor, one fewer failure mode, one fewer deployment concern.

**Incorrect (Redis-dependent infrastructure with multiple moving parts):**

```ruby
# Gemfile — three separate Redis-dependent gems
gem "sidekiq"
gem "redis"
gem "redis-actioncable"

# config/cable.yml — requires a running Redis instance
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
  channel_prefix: myapp_production

# config/environments/production.rb — Redis for everything
config.cache_store = :redis_cache_store, {
  url: ENV["REDIS_URL"],
  expires_in: 1.hour,
  error_handler: -> (method:, returning:, exception:) {
    Sentry.capture_exception(exception)
  }
}

config.active_job.queue_adapter = :sidekiq

# Procfile — two extra processes to manage
web: bin/rails server
worker: bundle exec sidekiq -C config/sidekiq.yml
redis: redis-server /usr/local/etc/redis.conf
```

**Correct (database-backed Solid stack with no external dependencies):**

```ruby
# Gemfile — the Solid trifecta, all database-backed
gem "solid_queue"
gem "solid_cable"
gem "solid_cache"

# config/cable.yml — backed by the database
production:
  adapter: solid_cable
  silence_polling: true
  polling_interval: 0.1.seconds

# config/environments/production.rb — everything goes through the database
config.cache_store = :solid_cache_store
config.active_job.queue_adapter = :solid_queue
config.solid_queue.connects_to = { database: { writing: :queue } }

# config/database.yml — dedicated databases for each concern
production:
  primary:
    <<: *default
    database: myapp_production
  queue:
    <<: *default
    database: myapp_production_queue
    migrations_paths: db/queue_migrate
  cable:
    <<: *default
    database: myapp_production_cable
    migrations_paths: db/cable_migrate
  cache:
    <<: *default
    database: myapp_production_cache
    migrations_paths: db/cache_migrate

# Procfile — just the web server, Solid Queue runs via puma plugin
web: bin/rails server
```

**When NOT to use:**
- If you have an existing large-scale Redis deployment with sub-millisecond latency requirements (e.g., rate limiting at 100k+ req/s), a hybrid approach may be warranted during migration.

**Benefits:**
- Single infrastructure dependency — one database engine to operate, back up, and monitor
- Jobs, cache entries, and broadcasts survive process restarts without data loss
- Development environment matches production exactly with zero extra setup
- Simplifies deployment to platforms like Kamal, Hatchbox, or bare metal

Reference: [37signals Dev Blog](https://dev.37signals.com/)
