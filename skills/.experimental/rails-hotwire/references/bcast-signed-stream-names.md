---
title: Use Signed Stream Names for Security
impact: MEDIUM-HIGH
impactDescription: "prevents stream hijacking via forged channel names"
tags: bcast, security, signed-streams, authorization
---

## Use Signed Stream Names for Security

Turbo uses cryptographically signed stream names to prevent unauthorized clients from subscribing to arbitrary channels. The `turbo_stream_from` helper automatically signs the stream name using Rails' secret key base, and the `Turbo::StreamsChannel` verifies this signature on subscription. Manually constructing channel subscriptions with unsigned names bypasses this protection, allowing any client to listen to any stream by guessing the name.

**Incorrect (broadcasting to predictable, unscoped stream names):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation

  # BAD: broadcasting to a string literal without resource scoping.
  # If two tenants share the same conversation ID (e.g., both have "1"),
  # their messages leak across organizations.
  broadcasts_refreshes_to "conversation_messages"
end
```

```erb
<%# BAD: subscribing to a generic string name instead of a scoped resource.
    Any user who guesses the stream name can subscribe. %>
<%= turbo_stream_from "conversation_messages" %>

<%# Also BAD: using just the record without tenant scoping in multi-tenant apps %>
<%= turbo_stream_from @conversation %>
<%# If tenant A's conversation #1 and tenant B's conversation #1 share the
    same signed stream name, broadcasts leak between tenants. %>
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
