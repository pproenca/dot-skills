---
title: Name Turbo Frames with a Consistent Prefix Convention
impact: LOW-MEDIUM
impactDescription: prevents frame ID collisions and improves debuggability
tags: org, turbo, naming, conventions
---

## Name Turbo Frames with a Consistent Prefix Convention

Turbo Frame IDs must be unique on the page. Generic names like `content` or `form` collide when multiple frames appear on the same page. Worse, Turbo silently breaks when IDs collide -- no error, just unexpected behavior. Use Rails' `dom_id` helper for resource-based frames and a consistent prefix for singleton frames.

**Incorrect (generic frame IDs that collide):**

```erb
<%# app/views/users/show.html.erb %>
<turbo-frame id="content">
  <%= @user.bio %>
</turbo-frame>

<%# app/views/users/_comment.html.erb — rendered multiple times on the same page %>
<turbo-frame id="comment">
  <%# Every comment has the same frame ID — only the first one works! %>
  <%= comment.body %>
</turbo-frame>

<%# app/views/orders/show.html.erb — "content" collides with user page %>
<turbo-frame id="content">
  <%= @order.summary %>
</turbo-frame>
```

**Correct (dom_id for resource frames, descriptive names for singletons):**

```erb
<%# Resource frames — use dom_id for guaranteed uniqueness %>
<turbo-frame id="<%= dom_id(@user, :profile) %>">
  <%# Generates: user_42_profile %>
  <%= @user.bio %>
</turbo-frame>

<%# Collection frames — each item gets a unique ID %>
<% @comments.each do |comment| %>
  <turbo-frame id="<%= dom_id(comment) %>">
    <%# Generates: comment_1, comment_2, comment_3, etc. %>
    <%= render comment %>
  </turbo-frame>
<% end %>

<%# Singleton frames — descriptive, namespaced names %>
<turbo-frame id="flash_messages">
  <%= render "shared/flash" %>
</turbo-frame>

<turbo-frame id="sidebar_navigation">
  <%= render "shared/sidebar" %>
</turbo-frame>

<turbo-frame id="user_search_results">
  <%= render @results %>
</turbo-frame>
```

The `dom_id` helper patterns:

```ruby
dom_id(User.new)              # => "new_user"
dom_id(User.find(42))         # => "user_42"
dom_id(User.find(42), :profile) # => "user_42_profile"
dom_id(User.find(42), :edit)    # => "user_42_edit"
```

For Turbo Stream responses, the frame IDs must match:

```erb
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append dom_id(@comment.post, :comments) do %>
  <turbo-frame id="<%= dom_id(@comment) %>">
    <%= render @comment %>
  </turbo-frame>
<% end %>
```

Naming convention summary:

| Frame Type | Pattern | Example |
|------------|---------|---------|
| Single resource | `dom_id(resource, :section)` | `user_42_profile` |
| Collection item | `dom_id(resource)` | `comment_7` |
| New resource form | `dom_id(Resource.new)` | `new_comment` |
| Singleton section | `{section}_name` (descriptive) | `flash_messages` |
| Search/filter results | `{resource}_{action}_results` | `user_search_results` |

Reference: [Turbo Frames](https://turbo.hotwired.dev/handbook/frames)
