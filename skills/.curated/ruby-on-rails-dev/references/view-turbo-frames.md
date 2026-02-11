---
title: Use Turbo Frames for Partial Page Updates
impact: MEDIUM-HIGH
impactDescription: eliminates full page reloads for in-page interactions
tags: view, turbo-frames, hotwire, spa-like, partial-updates
---

## Use Turbo Frames for Partial Page Updates

Full page reloads for inline edits and toggles waste bandwidth and break user focus. Turbo Frames replace only the targeted section of the page.

**Incorrect (full page reload for edit toggle):**

```erb
<!-- app/views/tasks/show.html.erb -->
<div class="task">
  <h2><%= @task.title %></h2>
  <p><%= @task.description %></p>
  <%= link_to "Edit", edit_task_path(@task) %>
</div>
```

**Correct (inline replacement with Turbo Frame):**

```erb
<!-- app/views/tasks/show.html.erb -->
<%= turbo_frame_tag @task do %>
  <div class="task">
    <h2><%= @task.title %></h2>
    <p><%= @task.description %></p>
    <%= link_to "Edit", edit_task_path(@task) %>
  </div>
<% end %>

<!-- app/views/tasks/edit.html.erb -->
<%= turbo_frame_tag @task do %>
  <%= render "form", task: @task %>
<% end %>
```

**Benefits:**
- No JavaScript required
- Automatic frame matching by DOM ID
- Progressive enhancement — works without JavaScript

Reference: [Turbo Frames — Hotwire](https://turbo.hotwired.dev/handbook/frames)
