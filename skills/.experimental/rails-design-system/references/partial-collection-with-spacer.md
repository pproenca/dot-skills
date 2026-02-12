---
title: Use Collection Rendering with Spacer Templates
impact: MEDIUM-HIGH
impactDescription: eliminates loop boilerplate and separator logic
tags: partial, views, collections, spacer, rendering
---

## Use Collection Rendering with Spacer Templates

Rails collection rendering supports spacer templates for separators between items. Use this instead of manual `each_with_index` loops that check for the last element. Collection rendering also provides automatic counter variables, handles empty collections gracefully, and is measurably faster than manual iteration because Rails optimizes the render path.

**Incorrect (manual loop with separator logic):**

```erb
<%# app/views/notifications/index.html.erb %>
<div class="notification-list">
  <% @notifications.each_with_index do |notification, index| %>
    <div class="notification">
      <p class="notification-title"><%= notification.title %></p>
      <p class="notification-body"><%= notification.body %></p>
      <time><%= time_ago_in_words(notification.created_at) %> ago</time>
    </div>
    <% unless index == @notifications.length - 1 %>
      <hr class="notification-divider">
    <% end %>
  <% end %>
</div>
```

**Correct (collection rendering with spacer template):**

```erb
<%# app/views/notifications/_notification.html.erb %>
<%# locals: (notification:) %>
<div class="notification">
  <p class="notification-title"><%= notification.title %></p>
  <p class="notification-body"><%= notification.body %></p>
  <time><%= time_ago_in_words(notification.created_at) %> ago</time>
</div>

<%# app/views/notifications/_notification_divider.html.erb %>
<hr class="notification-divider">

<%# app/views/notifications/index.html.erb %>
<div class="notification-list">
  <%= render partial: "notification",
             collection: @notifications,
             spacer_template: "notification_divider" %>
</div>
```

### Built-in Counter Variable

Collection rendering automatically provides a counter variable named `{partial_name}_counter`:

```erb
<%# app/views/steps/_step.html.erb %>
<%# locals: (step:) %>
<div class="step">
  <span class="step-number"><%= step_counter %></span>
  <h4><%= step.title %></h4>
  <p><%= step.description %></p>
</div>
```

### When CSS Is the Better Separator

If the separator is purely visual (a line, spacing, or border), prefer CSS over a spacer template. Spacer templates are best for semantic separators that carry meaning or complex markup.

```erb
<%# CSS gap approach — no spacer template needed %>
<div class="notification-list divide-y divide-gray-200">
  <%= render partial: "notification", collection: @notifications %>
</div>
```

Use spacer templates when the separator contains interactive elements, conditional logic, or semantic HTML (like `<hr>` with an ARIA role).

Reference: [Rails Collection Rendering](https://guides.rubyonrails.org/layouts_and_rendering.html#rendering-collections)
