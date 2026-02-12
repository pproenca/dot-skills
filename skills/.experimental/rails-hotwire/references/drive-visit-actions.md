---
title: Control History with Visit Actions
impact: HIGH
impactDescription: prevents broken back-button navigation
tags: drive, history, visit-action, navigation
---

## Control History with Visit Actions

Turbo Drive defaults to `"advance"` for link clicks, pushing a new entry onto the browser history stack. For search, filter, and sort interactions, use `data-turbo-action="replace"` to swap the current history entry instead. Without this, users pressing back after applying five filters must click back five times to leave the page.

**Incorrect (every interaction pushes to history, breaking back button):**

```erb
<%# Search form pushes a new history entry on every keystroke/submit %>
<%= form_with url: projects_path, method: :get do |f| %>
  <%= f.search_field :q, value: params[:q] %>
  <%= f.select :status, ["active", "archived"], selected: params[:status] %>
  <%= f.submit "Search" %>
<% end %>

<%# Sort links each push a new history entry %>
<%= link_to "Sort by date", projects_path(sort: :created_at) %>
<%= link_to "Sort by name", projects_path(sort: :name) %>
```

**Correct (replace history for filters, advance for navigation):**

```erb
<%# Search/filter form replaces the current history entry %>
<%= form_with url: projects_path, method: :get,
    data: { turbo_action: "replace" } do |f| %>
  <%= f.search_field :q, value: params[:q] %>
  <%= f.select :status, ["active", "archived"], selected: params[:status] %>
  <%= f.submit "Search" %>
<% end %>

<%# Sort links replace instead of pushing new history entries %>
<%= link_to "Sort by date", projects_path(sort: :created_at),
    data: { turbo_action: "replace" } %>
<%= link_to "Sort by name", projects_path(sort: :name),
    data: { turbo_action: "replace" } %>

<%# Navigation links correctly advance (default behavior) %>
<%= link_to "View project", project_path(@project) %>
```
