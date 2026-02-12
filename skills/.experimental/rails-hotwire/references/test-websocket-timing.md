---
title: Handle WebSocket Connection Timing in System Tests
impact: MEDIUM
impactDescription: prevents race conditions in broadcast-dependent tests
tags: test, websocket, actioncable, timing
---

## Handle WebSocket Connection Timing in System Tests

When a page includes `turbo_stream_from`, the browser establishes a WebSocket connection to ActionCable asynchronously. If the test triggers a broadcast-producing action (like creating a record) before the subscription is fully established, the broadcast fires but no client is listening, causing the test to time out waiting for content that was never received. Waiting for the `turbo-cable-stream-source` element to gain its `connected` attribute ensures the subscription is ready before proceeding.

**Incorrect (creating a record immediately after page load, before WebSocket connects):**

```ruby
# test/system/live_messages_test.rb
class LiveMessagesTest < ApplicationSystemTestCase
  test "new messages appear in real time" do
    visit project_path(projects(:web_app))

    # Race condition: WebSocket subscription may not be established yet
    Message.create!(
      project: projects(:web_app),
      user: users(:bob),
      body: "Hello from another user!"
    )

    # This fails intermittently because the broadcast fired
    # before the WebSocket connection was ready
    assert_text "Hello from another user!"
  end
end
```

**Correct (assert_selector "turbo-cable-stream-source[connected]" before triggering broadcast):**

```ruby
# test/system/live_messages_test.rb
class LiveMessagesTest < ApplicationSystemTestCase
  test "new messages appear in real time" do
    visit project_path(projects(:web_app))

    # Wait for the WebSocket subscription to be fully established
    assert_selector "turbo-cable-stream-source[connected]", visible: false

    # Now it's safe to trigger a broadcast
    Message.create!(
      project: projects(:web_app),
      user: users(:bob),
      body: "Hello from another user!"
    )

    # The broadcast will be received reliably
    assert_text "Hello from another user!"
  end

  test "multiple stream subscriptions are ready" do
    visit project_path(projects(:web_app))

    # Wait for ALL subscriptions on the page to connect
    assert_selector "turbo-cable-stream-source[connected]",
      visible: false,
      count: 2  # messages stream + notifications stream

    # Safe to trigger broadcasts on either channel
    Message.create!(project: projects(:web_app), user: users(:bob), body: "New message")
    Notification.create!(project: projects(:web_app), kind: :mention, user: users(:alice))

    assert_text "New message"
    assert_selector ".notification-badge", text: "1"
  end
end
```
