---
title: Scope Navigation Within Frames
impact: CRITICAL
impactDescription: prevents unintended full-page replacements
tags: frame, navigation, scope, target
---

## Scope Navigation Within Frames

Links and forms inside a Turbo Frame are scoped to that frame by default -- the response replaces only the frame content, not the entire page. When a link inside a frame should navigate the full page (e.g., clicking a record title to view its detail page), you must explicitly set `data-turbo-frame="_top"`. Conversely, use `data-turbo-frame` to target a different frame from outside it.

**Incorrect (link inside frame unexpectedly replacing entire page or wrong frame):**

```erb
<%# app/views/comments/_comment.html.erb %>
<%= turbo_frame_tag dom_id(comment) do %>
  <div class="comment">
    <p><%= comment.body %></p>

    <%# This link tries to navigate inside the comment frame,
        but the show page won't have a matching frame — shows nothing %>
    <%= link_to comment.author.name, user_path(comment.author) %>

    <%= link_to "Edit", edit_comment_path(comment) %>
  </div>
<% end %>
```

**Correct (explicit target controls for frame-scoped vs page-level navigation):**

```erb
<%# app/views/comments/_comment.html.erb %>
<%= turbo_frame_tag dom_id(comment) do %>
  <div class="comment">
    <p><%= comment.body %></p>

    <%# Break out of the frame — navigate the full page %>
    <%= link_to comment.author.name, user_path(comment.author),
        data: { turbo_frame: "_top" } %>

    <%# Stays within this frame — edit form replaces comment content %>
    <%= link_to "Edit", edit_comment_path(comment) %>
  </div>
<% end %>

<%# From outside the frame, target a specific frame %>
<%= link_to "Load latest comments",
    project_comments_path(@project),
    data: { turbo_frame: "project_comments" } %>
```

```erb
<%# app/views/comments/edit.html.erb %>
<%# The edit form must be wrapped in a matching frame %>
<%= turbo_frame_tag dom_id(@comment) do %>
  <%= render "form", comment: @comment %>
<% end %>
```
