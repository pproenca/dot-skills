---
title: Use Signed Stream Names for Security
impact: MEDIUM-HIGH
impactDescription: "prevents stream hijacking via forged channel names"
tags: bcast, security, signed-streams, authorization
---

## Use Signed Stream Names for Security

Turbo uses cryptographically signed stream names to prevent unauthorized clients from subscribing to arbitrary channels. The `turbo_stream_from` helper automatically signs the stream name using Rails' secret key base, and the `Turbo::StreamsChannel` verifies this signature on subscription. Manually constructing channel subscriptions with unsigned names bypasses this protection, allowing any client to listen to any stream by guessing the name.

**Incorrect (manually subscribing to unsigned stream names):**

```javascript
// app/javascript/channels/project_channel.js
import consumer from "./consumer";

// BAD: subscribing with a plain-text channel name
// Any user can change project_id to eavesdrop on other projects
consumer.subscriptions.create(
  {
    channel: "Turbo::StreamsChannel",
    signed_stream_name: `project_${projectId}_messages`,
  },
  {
    received(data) {
      document.getElementById("messages").insertAdjacentHTML("beforeend", data);
    },
  }
);
```

```erb
<%# BAD: constructing the subscription element manually %>
<turbo-cable-stream-source
  channel="Turbo::StreamsChannel"
  signed-stream-name="project_42_messages">
</turbo-cable-stream-source>
```

**Correct (turbo_stream_from helper that auto-signs):**

```erb
<%# app/views/projects/show.html.erb %>

<%# turbo_stream_from generates a signed stream name automatically.
    The signature is verified server-side on subscription. %>
<%= turbo_stream_from @project, :messages %>

<%# For multiple stream sources on the same page: %>
<%= turbo_stream_from @project, :tasks %>
<%= turbo_stream_from current_user, :notifications %>

<div id="messages">
  <%= render @project.messages %>
</div>
```

```ruby
# When broadcasting from server code, use the same streamable:
Turbo::StreamsChannel.broadcast_refresh_to(@project, :messages)

# The stream name is signed consistently on both ends.
# Never pass raw/unsigned strings to broadcast methods.
```
