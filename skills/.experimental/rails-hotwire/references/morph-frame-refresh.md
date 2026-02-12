---
title: Use refresh='morph' on Frames for Additive Content
impact: MEDIUM-HIGH
impactDescription: "enables pagination without losing existing content"
tags: morph, frames, pagination, refresh
---

## Use refresh='morph' on Frames for Additive Content

When a Turbo Frame loads paginated or lazy-loaded content and a page refresh occurs (via broadcast or navigation), the default behavior replaces the entire frame content with whatever the server renders for page 1. This wipes out content the user loaded via "Load More" or infinite scroll. Setting `refresh="morph"` on the frame tells Turbo to morph the frame's contents during a page refresh, preserving the existing DOM while patching in any changes.

**Incorrect (frame content wiped on page refresh, losing paginated results):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from @project %>

<h1><%= @project.name %></h1>

<%# User clicks "Load More" three times, loading 60 tasks.
    Another user updates a task, triggering broadcasts_refreshes.
    The page morphs and this frame is replaced with the server response,
    which only contains the first 20 tasks. 40 tasks disappear. %>
<%= turbo_frame_tag "tasks_list" do %>
  <div id="tasks">
    <%= render @tasks %>
  </div>

  <% if @tasks.next_page %>
    <%= link_to "Load More",
          project_tasks_path(@project, page: @tasks.next_page),
          data: { turbo_frame: "tasks_list" } %>
  <% end %>
<% end %>
```

**Correct (refresh="morph" on frame to preserve content across refreshes):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from @project %>

<h1><%= @project.name %></h1>

<%# refresh="morph" tells Turbo to morph the frame contents instead of replacing.
    Loaded pages are preserved; only changed elements are patched. %>
<%= turbo_frame_tag "tasks_list", refresh: "morph" do %>
  <div id="tasks">
    <%= render @tasks %>
  </div>

  <% if @tasks.next_page %>
    <%= link_to "Load More",
          project_tasks_path(@project, page: @tasks.next_page),
          data: { turbo_frame: "tasks_list" } %>
  <% end %>
<% end %>

<%# Now when a broadcast triggers a page refresh:
    - Tasks already loaded via pagination stay in the DOM
    - Any changed task content is morphed in place
    - The "Load More" link state is preserved %>
```
