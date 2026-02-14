---
title: Solid Cache for Application Caching
impact: MEDIUM
impactDescription: disk-backed cache that survives restarts, no Redis required
tags: db, solid-cache, caching, infrastructure
---

## Solid Cache for Application Caching

Use Solid Cache as part of the Solid trifecta for database-backed application caching. Unlike Redis, Solid Cache persists to disk and survives process restarts without cold-cache penalties. Combined with HTTP caching (`fresh_when`), fragment caching, and query caching, it forms a multi-layer caching strategy that needs no external dependencies.

**Incorrect (Redis-backed cache store with cold-start vulnerability):**

```ruby
# config/environments/production.rb — Redis dependency for caching
config.cache_store = :redis_cache_store, {
  url: ENV["REDIS_URL"],
  expires_in: 1.hour,
  namespace: "myapp",
  pool_size: 5,
  error_handler: -> (method:, returning:, exception:) {
    Sentry.capture_exception(exception)
  }
}

# Redis restart = entire cache is gone, thundering herd on cold start
# Must provision and monitor Redis memory separately
# Cache eviction under memory pressure is unpredictable

# app/controllers/recordings_controller.rb — no HTTP caching layer
class RecordingsController < ApplicationController
  def show
    @recording = Recording.find(params[:id])
    @comments = Rails.cache.fetch("recording/#{@recording.id}/comments", expires_in: 15.minutes) do
      @recording.comments.includes(:creator).to_a
    end
  end
end
```

**Correct (Solid Cache with multi-layer caching strategy):**

```ruby
# config/environments/production.rb — database-backed cache
config.cache_store = :solid_cache_store
config.solid_cache.connects_to = { database: { writing: :cache } }

# config/solid_cache.yml
production:
  store_options:
    max_age: 1.week
    max_size: 256.megabytes
    namespace: null

# config/database.yml — dedicated cache database
production:
  cache:
    <<: *default
    database: myapp_production_cache
    migrations_paths: db/cache_migrate

# app/controllers/recordings_controller.rb — layered caching
class RecordingsController < ApplicationController
  def show
    @recording = Recording.find(params[:id])

    # Layer 1: HTTP caching — avoids hitting Rails entirely on 304
    fresh_when @recording, public: false

    # Layer 2: Fragment caching in views (cache key auto-expires on update)
    # <%= cache @recording do %>
    #   <%= render @recording.comments %>
    # <% end %>
  end

  def index
    @recordings = Current.account.recordings.active

    # Layer 3: Application cache for expensive aggregations
    @stats = Rails.cache.fetch(["recording_stats", Current.account], expires_in: 1.hour) do
      {
        total: @recordings.count,
        total_duration: @recordings.sum(:duration),
        by_type: @recordings.group(:type).count
      }
    end
  end
end
```

**Benefits:**
- Cache survives deployments and process restarts — no cold-start thundering herd
- Disk is cheaper than RAM — cache more data for longer at lower cost
- Same backup and replication strategy as your primary database
- `max_size` provides predictable eviction, unlike Redis memory pressure surprises

Reference: [37signals Dev Blog](https://dev.37signals.com/)
