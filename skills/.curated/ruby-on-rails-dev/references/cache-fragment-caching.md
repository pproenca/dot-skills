---
title: Use Fragment Caching for Expensive View Partials
impact: HIGH
impactDescription: 10-50× faster rendering for cached partials
tags: cache, fragment-caching, views, partials
---

## Use Fragment Caching for Expensive View Partials

Re-rendering complex partials on every request wastes CPU. Fragment caching stores rendered HTML and serves it directly on subsequent requests.

**Incorrect (re-renders on every request):**

```erb
<!-- app/views/projects/show.html.erb -->
<div class="project-stats">
  <h2><%= @project.name %> Statistics</h2>
  <p>Total tasks: <%= @project.tasks.count %></p>
  <p>Completed: <%= @project.tasks.completed.count %></p>
  <p>Contributors: <%= @project.members.count %></p>
  <%= render partial: "activity_feed", collection: @project.recent_activities %>
</div>
```

**Correct (cached fragment):**

```erb
<!-- app/views/projects/show.html.erb -->
<% cache @project do %>
  <div class="project-stats">
    <h2><%= @project.name %> Statistics</h2>
    <p>Total tasks: <%= @project.tasks.count %></p>
    <p>Completed: <%= @project.tasks.completed.count %></p>
    <p>Contributors: <%= @project.members.count %></p>
    <%= render partial: "activity_feed", collection: @project.recent_activities %>
  </div>
<% end %>
```

**Benefits:**
- Cache key auto-expires when `@project.updated_at` changes
- Zero code changes needed for cache invalidation with touch

Reference: [Caching with Rails — Rails Guides](https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching)
