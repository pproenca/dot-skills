---
title: Promote Frame Navigation to Page Visits
impact: HIGH
impactDescription: enables URL updates and browser history from frame interactions
tags: frame, promote, history, url
---

## Promote Frame Navigation to Page Visits

By default, Turbo Frame navigations do not update the browser URL or push entries to the history stack. For interactions where the URL matters -- pagination, tab switching, filtering within a frame -- add `data-turbo-action="advance"` to make the frame navigation update the address bar. This preserves shareability, bookmarkability, and proper browser back/forward behavior.

**Incorrect (frame navigation that doesn't update URL, breaking shareability):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project) do %>
  <p>Loading comments...</p>
<% end %>

<%# app/views/comments/_pagination.html.erb %>
<%# Clicking page 3 loads comments but URL stays on /projects/1
    — user can't share or bookmark page 3 of comments %>
<%= turbo_frame_tag "project_comments" do %>
  <div class="comments">
    <%= render @comments %>
  </div>
  <nav class="pagination">
    <%= link_to "Previous", project_comments_path(@project, page: @page - 1) %>
    <%= link_to "Next", project_comments_path(@project, page: @page + 1) %>
  </nav>
<% end %>
```

**Correct (frame navigation promoted to page visits with URL updates):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project) do %>
  <p>Loading comments...</p>
<% end %>

<%# app/views/comments/_pagination.html.erb %>
<%# data-turbo-action="advance" updates the URL when navigating %>
<%= turbo_frame_tag "project_comments" do %>
  <div class="comments">
    <%= render @comments %>
  </div>
  <nav class="pagination">
    <%= link_to "Previous",
        project_comments_path(@project, page: @page - 1),
        data: { turbo_action: "advance" } %>
    <%= link_to "Next",
        project_comments_path(@project, page: @page + 1),
        data: { turbo_action: "advance" } %>
  </nav>
<% end %>

<%# For tab interfaces, promote tab selection to URL %>
<div class="tabs">
  <%= link_to "Overview",
      project_overview_path(@project),
      data: { turbo_frame: "tab_content", turbo_action: "advance" } %>
  <%= link_to "Members",
      project_members_path(@project),
      data: { turbo_frame: "tab_content", turbo_action: "advance" } %>
</div>

<%= turbo_frame_tag "tab_content",
    src: project_overview_path(@project) do %>
  <p>Loading...</p>
<% end %>
```
