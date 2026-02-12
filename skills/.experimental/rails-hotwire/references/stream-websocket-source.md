---
title: Connect WebSocket Sources in the Body
impact: MEDIUM-HIGH
impactDescription: "prevents stream disconnection on Turbo navigation"
tags: stream, websocket, turbo-stream-from, placement
---

## Connect WebSocket Sources in the Body

The `turbo_stream_from` helper subscribes the client to an Action Cable channel for receiving broadcast streams. If placed inside a `<head>` element or inside a Turbo Frame that gets replaced during navigation, the subscription is silently destroyed and real-time updates stop arriving. Placing it in the `<body>`, outside any Turbo Frame that might be swapped, ensures the subscription persists across frame navigations.

**Incorrect (turbo_stream_from in head or in a replaceable frame):**

```erb
<%# app/views/layouts/application.html.erb %>
<html>
<head>
  <%# BAD: subscriptions in <head> are not processed by Turbo %>
  <%= turbo_stream_from @project %>
</head>
<body>
  <%= yield %>
</body>
</html>

<%# Or worse: inside a frame that gets replaced %>
<%= turbo_frame_tag "project_detail" do %>
  <%= turbo_stream_from @project %>
  <h1><%= @project.name %></h1>
  <%# When this frame is replaced, the subscription is destroyed %>
<% end %>
```

**Correct (turbo_stream_from in body, outside replaceable frames):**

```erb
<%# app/views/projects/show.html.erb %>

<%# Stream source in body, outside any frame that might be replaced %>
<%= turbo_stream_from @project %>

<%= turbo_frame_tag "project_detail" do %>
  <h1><%= @project.name %></h1>
  <div id="tasks">
    <%= render @project.tasks %>
  </div>
<% end %>

<%# For user-scoped streams, use an array to auto-generate signed names %>
<%= turbo_stream_from current_user, :notifications %>

<%# The signed stream name prevents other users from subscribing to this channel.
    turbo_stream_from handles signing automatically — never construct
    channel names manually. %>
```
