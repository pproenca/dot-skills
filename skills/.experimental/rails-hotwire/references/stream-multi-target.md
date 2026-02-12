---
title: Use targets for Multi-Element Updates
impact: HIGH
impactDescription: "eliminates N separate stream tags for batch updates"
tags: stream, targets, batch-updates, selectors
---

## Use targets for Multi-Element Updates

When a single action must update several elements sharing a common pattern (badges, counters, status indicators), emitting one stream tag per element creates bloated responses and forces you to track every DOM ID. The `targets` attribute (plural) accepts a CSS selector and applies the action to all matching elements in one declaration, reducing response size and keeping the stream template maintainable.

**Incorrect (multiple turbo_stream tags each targeting one element):**

```erb
<%# Updates unread count in 4 different places on the page %>
<%= turbo_stream.update "header_unread_count" do %>
  <span><%= current_user.unread_messages_count %></span>
<% end %>

<%= turbo_stream.update "sidebar_unread_count" do %>
  <span><%= current_user.unread_messages_count %></span>
<% end %>

<%= turbo_stream.update "mobile_nav_unread_count" do %>
  <span><%= current_user.unread_messages_count %></span>
<% end %>

<%= turbo_stream.update "tab_unread_count" do %>
  <span><%= current_user.unread_messages_count %></span>
<% end %>
```

**Correct (single turbo_stream with targets CSS selector):**

```erb
<%# One stream tag updates every element matching the selector %>
<%= turbo_stream.update_all ".unread-messages-count" do %>
  <span><%= current_user.unread_messages_count %></span>
<% end %>

<%# In the views, mark all badge locations with the shared class and unique IDs: %>
<%# header:  <span id="header_unread_count" class="unread-messages-count">3</span> %>
<%# sidebar: <span id="sidebar_unread_count" class="unread-messages-count">3</span> %>
<%# mobile:  <span id="mobile_nav_unread_count" class="unread-messages-count">3</span> %>

<%# For raw Turbo Stream HTML (e.g., in a broadcast job): %>
<%# <turbo-stream action="update" targets=".unread-messages-count"> %>
<%#   <template><span>5</span></template> %>
<%# </turbo-stream> %>
```
