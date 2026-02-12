---
title: Assert Broadcasts with Turbo Test Helpers
impact: MEDIUM
impactDescription: catches 100% of silent broadcast regressions before deploy
tags: test, broadcasts, actioncable, model
---

## Assert Broadcasts with Turbo Test Helpers

Model-level broadcasts via `broadcasts_to` or `broadcasts_refreshes_to` are critical for real-time features but are easy to leave untested because they require no explicit controller code. The `Turbo::Broadcastable::TestHelper` module provides `assert_turbo_stream_broadcasts` to verify that creating, updating, or destroying records enqueues the expected broadcast payloads, all without needing a running WebSocket server or browser.

**Incorrect (no test coverage for broadcast side effects):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :project
  broadcasts_refreshes_to :project
end

# test/models/message_test.rb
class MessageTest < ActiveSupport::TestCase
  test "message belongs to project" do
    message = Message.new(project: projects(:web_app), body: "Hello")
    assert message.valid?
  end

  # No tests verify that broadcasts actually fire!
  # A typo in the stream name or a missing callback silently breaks real-time updates
end
```

**Correct (assert_turbo_stream_broadcasts verifies broadcasts fire):**

```ruby
# test/models/message_test.rb
class MessageTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "creating a message broadcasts a refresh to the project" do
    project = projects(:web_app)

    assert_turbo_stream_broadcasts(project) do
      Message.create!(project: project, body: "Hello team!", user: users(:alice))
    end
  end

  test "updating a message broadcasts a refresh" do
    message = messages(:greeting)

    assert_turbo_stream_broadcasts(message.project) do
      message.update!(body: "Updated greeting")
    end
  end

  test "suppressed broadcasts do not fire" do
    project = projects(:web_app)

    assert_no_turbo_stream_broadcasts(project) do
      Message.suppressing_turbo_broadcasts do
        Message.create!(project: project, body: "Silent", user: users(:alice))
      end
    end
  end
end
```

Reference: [Turbo Broadcastable TestHelper — turbo-rails](https://github.com/hotwired/turbo-rails)
