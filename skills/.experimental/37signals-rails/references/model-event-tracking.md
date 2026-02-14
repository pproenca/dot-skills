---
title: Polymorphic Event Model for Activity Tracking
impact: HIGH
impactDescription: single source of truth for all activity — drives timelines, notifications, and webhooks from one table
tags: model, events, activity, polymorphic, webhooks
---

## Polymorphic Event Model for Activity Tracking

Use a polymorphic `Event` model as the single source of truth for all activity in the application. Every significant action — card closed, comment created, user assigned — creates an Event record. Events drive activity timelines, notification delivery, and webhook dispatch. The `Eventable` concern provides a `track_event` method that models include to record actions automatically.

**Incorrect (scattered activity tracking across the codebase):**

```ruby
# Activity tracked differently in every model
class Card < ApplicationRecord
  after_update :log_changes

  private

  def log_changes
    # Custom activity logging per model
    ActivityLog.create!(
      model_type: "Card",
      model_id: id,
      changes: saved_changes.to_json,
      user_id: Current.user&.id
    )
  end
end

# Notifications handled separately
class Comment < ApplicationRecord
  after_create_commit :send_notifications

  private

  def send_notifications
    # Direct notification logic, not connected to activity
    card.watchers.each do |watcher|
      NotificationMailer.new_comment(watcher, self).deliver_later
    end
  end
end

# Webhooks in a completely separate system
class WebhookDispatcher
  def self.dispatch(action, resource)
    Webhook.active.each { |wh| wh.deliver(action, resource) }
  end
end
```

**Correct (Event model with Eventable concern):**

```ruby
# app/models/event.rb — single source of truth
class Event < ApplicationRecord
  belongs_to :eventable, polymorphic: true
  belongs_to :creator, class_name: "User"
  store_accessor :particulars  # JSON column for action-specific metadata

  after_create_commit :dispatch_webhooks
  after_create_commit :deliver_notifications

  scope :chronologically, -> { order(created_at: :asc) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }

  private
  def dispatch_webhooks = WebhookDeliveryJob.perform_later(self)
  def deliver_notifications = NotificationDeliveryJob.perform_later(self)
end

# app/models/concerns/eventable.rb
module Eventable
  extend ActiveSupport::Concern
  included { has_many :events, as: :eventable, dependent: :destroy }

  def track_event(action, creator: Current.user, particulars: {})
    events.create!(action: action, creator: creator, particulars: particulars)
  end
end
```

**Correct (usage in models):**

```ruby
# app/models/card.rb
class Card < ApplicationRecord
  include Eventable

  def close!(by:)
    update!(closed_at: Time.current)
    track_event("card_closed", creator: by)
  end

  def assign!(to:, by:)
    update!(assignee: to)
    track_event("card_assigned", creator: by, particulars: { assignee_id: to.id })
  end
end

# app/models/comment.rb
class Comment < ApplicationRecord
  include Eventable
  after_create_commit -> { track_event("comment_created") }
end

# Activity timeline — one query
Event.where(eventable: @card).reverse_chronologically
```

**Benefits:**
- One table, one model, one query for all activity
- Webhooks and notifications wired once in Event, not per-model
- `particulars` JSON stores action-specific metadata without extra columns
- Activity feed is a single `Event.where(eventable:)` query
- Adding a new tracked action requires only a `track_event` call

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
