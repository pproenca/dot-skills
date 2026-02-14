---
title: Callbacks for Auxiliary Complexity
impact: MEDIUM
impactDescription: reduces controller action size by 50-70%
tags: model, callbacks, side-effects, after-commit
---

## Callbacks for Auxiliary Complexity

Use callbacks — especially `after_create_commit` and `after_update_commit` — to handle auxiliary concerns like notifications, webhooks, search indexing, and activity logging. This keeps the primary create/update path focused on the core domain operation. The caller says `recording.publish!` and gets exactly one responsibility; the model itself orchestrates the side effects that follow, discoverable by reading the class.

**Incorrect (side effects inlined in controller and domain methods):**

```ruby
# app/controllers/recordings_controller.rb
def create
  @recording = current_bucket.recordings.create!(recording_params)

  # Side effects mixed into the controller
  @recording.subscribers.each do |subscriber|
    RecordingMailer.new_recording(subscriber, @recording).deliver_later
  end
  SearchIndex.reindex(@recording)
  WebhookDelivery.enqueue(@recording, event: "recording.created")
  Event.create!(action: "created", recordable: @recording, creator: Current.person)

  redirect_to @recording
end

# Every action that creates a recording must repeat these side effects
# API controller, import job, console usage — all must remember to notify, index, webhook
```

**Correct (callbacks handle auxiliary concerns):**

```ruby
# app/models/recording.rb
class Recording < ApplicationRecord
  include Eventable
  include Searchable
  include Webhookable

  has_many :subscribers, through: :subscriptions

  after_create_commit :notify_subscribers
  after_create_commit :deliver_webhooks

  private

  def notify_subscribers
    subscribers.each do |subscriber|
      RecordingMailer.new_recording(subscriber, self).deliver_later
    end
  end
end

# app/models/concerns/eventable.rb
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :recordable
    after_create_commit -> { events.create!(action: "created", creator: Current.person) }
  end
end

# app/controllers/recordings_controller.rb — clean, one responsibility
def create
  @recording = current_bucket.recordings.create!(recording_params)
  redirect_to @recording
end

# API controller, import job, console — all get the same side effects automatically
```

**When NOT to use:**
- Callbacks that silently prevent saves (`before_validation` returning false) create hard-to-debug failures. Keep callbacks to post-commit side effects that do not affect the outcome of the primary operation.

Reference: [On Writing Software Well](https://signalvnoise.com/svn3/on-writing-software-well/)
