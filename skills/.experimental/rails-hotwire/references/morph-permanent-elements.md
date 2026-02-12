---
title: Mark Stateful Elements as Permanent
impact: HIGH
impactDescription: "prevents loss of open dropdowns, modals, and form input"
tags: morph, permanent, state-preservation, data-attribute
---

## Mark Stateful Elements as Permanent

Even with morphing enabled, Turbo may still replace elements whose server-rendered HTML differs from their current client-side state (open dropdowns, playing videos, partially filled forms). Adding `data-turbo-permanent` to these elements tells Turbo to skip them entirely during morphing, preserving whatever state the user has built up. Each permanent element must have a unique `id` so Turbo can match it across renders.

**Incorrect (dropdown closing every time a broadcast triggers page morph):**

```erb
<%# app/views/shared/_notification_dropdown.html.erb %>

<%# No permanent marker — morph replaces this with server HTML (closed state) %>
<div id="notification_dropdown" class="dropdown">
  <button data-controller="dropdown" data-action="click->dropdown#toggle">
    Notifications (<%= current_user.unread_notifications_count %>)
  </button>
  <div class="dropdown-menu" data-dropdown-target="menu">
    <%= render current_user.notifications.recent %>
  </div>
</div>

<%# When another user creates a task and triggers a broadcast_refresh,
    the morph replaces this element with the server-rendered closed state,
    snapping the dropdown shut while the user is reading it. %>
```

**Correct (data-turbo-permanent with unique id on stateful elements):**

```erb
<%# app/views/shared/_notification_dropdown.html.erb %>

<%# Permanent marker preserves client-side state across morphs %>
<div id="notification_dropdown" data-turbo-permanent class="dropdown">
  <button data-controller="dropdown" data-action="click->dropdown#toggle">
    Notifications (<%= current_user.unread_notifications_count %>)
  </button>
  <div class="dropdown-menu" data-dropdown-target="menu">
    <%= render current_user.notifications.recent %>
  </div>
</div>

<%# To update the count inside a permanent element, use a Turbo Stream
    that targets a child element specifically: %>
<%= turbo_stream.update "notification_count" do %>
  <%= current_user.unread_notifications_count %>
<% end %>

<%# In the dropdown, wrap the count in a targetable span: %>
<%# <span id="notification_count">5</span> %>
```
