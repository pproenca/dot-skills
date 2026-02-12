---
title: Defer Frame Loading Until Viewport Entry
impact: CRITICAL
impactDescription: reduces initial page requests from 11 to 1, time to interactive from 2.4s to 0.7s
tags: frame, lazy-loading, performance, viewport
---

## Defer Frame Loading Until Viewport Entry

Turbo Frames with `loading: :lazy` defer their `src` request until the frame enters the viewport. On pages with multiple independent sections (comments, activity feeds, related items), eager-loading all frames fires parallel requests on page load, increasing time to interactive and wasting bandwidth for content users may never scroll to.

**Incorrect (eager-loading all frames on page load):**

```erb
<%# app/views/projects/show.html.erb %>
<%# All 4 frames fire requests immediately on page load %>
<h1><%= @project.name %></h1>

<%= turbo_frame_tag "project_details",
    src: project_details_path(@project) do %>
  <p>Loading details...</p>
<% end %>

<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project) do %>
  <p>Loading comments...</p>
<% end %>

<%= turbo_frame_tag "project_activity",
    src: project_activity_path(@project) do %>
  <p>Loading activity...</p>
<% end %>

<%= turbo_frame_tag "related_projects",
    src: related_projects_path(@project) do %>
  <p>Loading related...</p>
<% end %>
```

**Correct (lazy-load below-fold content, eager-load above-fold):**

```erb
<%# app/views/projects/show.html.erb %>
<h1><%= @project.name %></h1>

<%# Above the fold — load immediately (no loading: option needed) %>
<%= turbo_frame_tag "project_details",
    src: project_details_path(@project) do %>
  <p>Loading details...</p>
<% end %>

<%# Below the fold — lazy-load when user scrolls to them %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project),
    loading: :lazy do %>
  <div class="skeleton skeleton-comments">Loading comments...</div>
<% end %>

<%= turbo_frame_tag "project_activity",
    src: project_activity_path(@project),
    loading: :lazy do %>
  <div class="skeleton skeleton-activity">Loading activity...</div>
<% end %>

<%= turbo_frame_tag "related_projects",
    src: related_projects_path(@project),
    loading: :lazy do %>
  <div class="skeleton skeleton-cards">Loading related...</div>
<% end %>
```
