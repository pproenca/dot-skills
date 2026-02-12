---
title: Scope Broadcast Streams to Accounts or Users
impact: HIGH
impactDescription: "prevents data leaks between tenants"
tags: bcast, security, multi-tenancy, stream-scoping
---

## Scope Broadcast Streams to Accounts or Users

Broadcasting to a generic stream name like `"messages"` means every subscriber receives every broadcast regardless of which account, project, or team they belong to. In a multi-tenant application, this leaks data across organizational boundaries. Always scope stream names to the owning resource (account, project, team) so that only authorized subscribers receive updates.

**Incorrect (broadcasting to a global stream visible to all users):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation

  # BAD: all users subscribed to "messages" see every message
  broadcasts_refreshes_to "messages"
end
```

```erb
<%# app/views/conversations/show.html.erb %>

<%# BAD: subscribes to a global stream — receives messages from all conversations %>
<%= turbo_stream_from "messages" %>

<div id="messages">
  <%= render @conversation.messages %>
</div>
```

**Correct (broadcasting to scoped stream with resource association):**

```ruby
# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :conversation

  # Stream is scoped to the specific conversation
  broadcasts_refreshes_to :conversation
end
```

```erb
<%# app/views/conversations/show.html.erb %>

<%# Subscribes to this conversation's signed stream only %>
<%= turbo_stream_from @conversation %>

<div id="messages">
  <%= render @conversation.messages %>
</div>

<%# For deeper scoping (e.g., account + resource), use an array: %>
<%# turbo_stream_from generates a signed name from all components,
    preventing cross-tenant subscription even if IDs collide %>
<%= turbo_stream_from current_user.account, @conversation %>
```
