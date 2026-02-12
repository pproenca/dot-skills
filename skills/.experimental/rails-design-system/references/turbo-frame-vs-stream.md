---
title: Choose Turbo Frames vs Turbo Streams by Scope of Change
impact: HIGH
impactDescription: prevents using the wrong Turbo primitive for each interaction pattern
tags: turbo, frames, streams, decision
---

## Choose Turbo Frames vs Turbo Streams by Scope of Change

Turbo Frames and Turbo Streams solve different problems. Frames scope a navigation to replace a single container. Streams update multiple elements from a single response. Using the wrong one leads to either over-engineering (Streams for a simple inline edit) or impossible interactions (Frames when you need to update a counter and a list simultaneously).

**Incorrect (using Turbo Streams for a simple inline edit):**

```erb
<%# Over-engineered: Streams for a single-element replacement %>
<%# app/views/users/update.turbo_stream.erb %>
<%= turbo_stream.replace dom_id(@user, :profile) do %>
  <%= render "users/profile", user: @user %>
<% end %>
```

A Turbo Frame handles this automatically — no `.turbo_stream.erb` template needed.

**Correct (Frame for single-element, Stream for multi-element):**

```erb
<%# FRAME: Inline edit — clicking Edit replaces just this section %>
<%= turbo_frame_tag dom_id(@user, :profile) do %>
  <h2><%= @user.name %></h2>
  <%= link_to "Edit", edit_user_path(@user) %>
<% end %>
```

```erb
<%# STREAM: Creating a comment updates the list AND the counter %>
<%# app/views/comments/create.turbo_stream.erb %>
<%= turbo_stream.append dom_id(@post, :comments) do %>
  <%= render @comment %>
<% end %>

<%= turbo_stream.update "comment-count", @post.comments.count %>
```

### Decision Checklist

| Question | Frame | Stream |
|---|---|---|
| How many page sections change? | Exactly 1 | 2 or more |
| Is it a navigation (link click)? | Usually yes | Usually no |
| Is it a form submission? | Works for single-target | Needed for multi-target |
| Do other users need the update? | No (request-scoped) | Yes (broadcast via ActionCable) |
| Need to remove a deleted element? | Awkward | `turbo_stream.remove` |

### Common Patterns

```text
Inline edit/show toggle       → Turbo Frame
Tab content switching          → Turbo Frame with lazy loading
Search with live results       → Turbo Frame with src
Add item to list               → Turbo Stream (append + update counter)
Delete item from list          → Turbo Stream (remove + update counter)
Form with flash message        → Turbo Stream (replace form + prepend flash)
Live chat / notifications      → Turbo Stream broadcast via ActionCable
Full page navigation           → Neither — Turbo Drive handles it
```

**When NOT to use this pattern:** If your interaction is a simple full-page navigation (clicking a nav link), let Turbo Drive handle it. Turbo Drive intercepts standard link clicks and form submissions automatically, replacing the `<body>` without a full page reload. You don't need to add Turbo Frames or Streams for basic navigation.

Reference: [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
