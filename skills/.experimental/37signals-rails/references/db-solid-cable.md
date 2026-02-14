---
title: Solid Cable for Real-Time Pub/Sub
impact: MEDIUM-HIGH
impactDescription: eliminates Redis for ActionCable, database-only real-time with 0.1s polling
tags: db, solid-cable, action-cable, real-time
---

## Solid Cable for Real-Time Pub/Sub

Use Solid Cable instead of Redis for ActionCable WebSocket pub/sub. It polls the database at 0.1-second intervals, providing near-real-time updates without an external message broker. Broadcasts are automatically scoped by account for multi-tenancy, and stale messages are trimmed on a configurable schedule to keep the table lean.

**Incorrect (Redis-backed ActionCable requiring separate infrastructure):**

```ruby
# config/cable.yml — requires Redis to be running and reachable
production:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") %>
  channel_prefix: myapp_production

# app/channels/card_channel.rb — manual tenant scoping in every channel
class CardChannel < ApplicationCable::Channel
  def subscribed
    # Must manually scope to prevent cross-tenant data leaks
    board = Current.account.boards.find(params[:board_id])
    stream_for board
  rescue ActiveRecord::RecordNotFound
    reject
  end
end

# Broadcasting requires constructing the stream name manually
CardChannel.broadcast_to(
  board,
  { action: "created", card: card.as_json }
)
```

**Correct (Solid Cable with database-backed pub/sub and automatic scoping):**

```ruby
# config/cable.yml — backed entirely by the database
production:
  adapter: solid_cable
  silence_polling: true
  polling_interval: 0.1.seconds
  message_retention: 1.hour

# config/database.yml — dedicated cable database
production:
  cable:
    <<: *default
    database: myapp_production_cable
    migrations_paths: db/cable_migrate

# app/channels/application_cable/connection.rb — tenant-aware connection
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_account

    def connect
      self.current_user = find_verified_user
      self.current_account = current_user.account
    end

    private

    def find_verified_user
      User.find_by(id: cookies.signed[:user_id]) || reject_unauthorized_connection
    end
  end
end

# app/channels/card_channel.rb — scoping handled by connection identity
class CardChannel < ApplicationCable::Channel
  def subscribed
    board = current_account.boards.find(params[:board_id])
    stream_for board
  end
end

# Broadcasting is identical — Solid Cable is a drop-in adapter swap
CardChannel.broadcast_to(board, { action: "created", card: card.as_json })
```

**When NOT to use:**
- Applications with thousands of concurrent WebSocket connections pushing updates multiple times per second (e.g., live trading dashboards) may need Redis pub/sub or AnyCable for lower latency. For typical collaboration tools, 0.1s polling is imperceptible to users.

Reference: [37signals Dev Blog](https://dev.37signals.com/)
