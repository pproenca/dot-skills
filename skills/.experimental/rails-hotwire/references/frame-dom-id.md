---
title: Use dom_id for Frame Identification
impact: MEDIUM-HIGH
impactDescription: prevents frame ID collisions and simplifies matching
tags: frame, dom-id, naming, collections
---

## Use dom_id for Frame Identification

Rails' `dom_id` helper generates unique, deterministic IDs from Active Record objects (e.g., `message_42`). When rendering collections of framed items, hardcoded string IDs collide and cause Turbo to match the wrong frame. Passing a model directly to `turbo_frame_tag` calls `dom_id` internally, ensuring each frame has a unique, consistent identifier that matches between the list view and the edit/show response.

**Incorrect (hardcoded string IDs that collide in collections):**

```erb
<%# app/views/messages/_message.html.erb %>
<%# Every message gets the same frame ID — Turbo can't distinguish them %>
<%= turbo_frame_tag "message" do %>
  <div class="message">
    <p><%= message.body %></p>
    <%= link_to "Edit", edit_message_path(message) %>
  </div>
<% end %>

<%# Or manually constructing IDs with inconsistent formats %>
<%= turbo_frame_tag "msg-#{message.id}" do %>
  <div class="message">
    <p><%= message.body %></p>
    <%= link_to "Edit", edit_message_path(message) %>
  </div>
<% end %>

<%# app/views/messages/edit.html.erb %>
<%# Must match the exact same format — easy to get wrong %>
<%= turbo_frame_tag "msg-#{@message.id}" do %>
  <%= render "form", message: @message %>
<% end %>
```

**Correct (dom_id via model object for automatic, collision-free IDs):**

```erb
<%# app/views/messages/_message.html.erb %>
<%# Passing the model directly calls dom_id — generates "message_42" %>
<%= turbo_frame_tag message do %>
  <div class="message">
    <p><%= message.body %></p>
    <%= link_to "Edit", edit_message_path(message) %>
  </div>
<% end %>

<%# app/views/messages/edit.html.erb %>
<%# Matching frame — also uses dom_id via the model %>
<%= turbo_frame_tag @message do %>
  <%= render "form", message: @message %>
<% end %>

<%# For new records, dom_id generates "new_message" %>
<%# app/views/messages/new.html.erb %>
<%= turbo_frame_tag Message.new do %>
  <%= render "form", message: @message %>
<% end %>

<%# You can also use dom_id with a prefix for multiple frames per model %>
<%= turbo_frame_tag dom_id(message, :comments) do %>
  <%# Generates "comments_message_42" %>
  <%= render message.comments %>
<% end %>
```
