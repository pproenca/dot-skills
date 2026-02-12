---
title: Decompose Pages into Turbo Frames for Targeted Updates
impact: HIGH
impactDescription: eliminates full-page reloads for 60-80% of user interactions
tags: turbo, frames, navigation, partial-updates
---

## Decompose Pages into Turbo Frames for Targeted Updates

Turbo Frames let you update a section of the page without a full reload. Wrap the section you want to update in a `<turbo-frame>` tag, and links and forms within that frame automatically scope their responses to replace only that frame. This gives you SPA-like partial page updates with zero custom JavaScript.

**Incorrect (full-page reload for every interaction):**

```erb
<%# app/views/users/show.html.erb %>
<%# Clicking "Edit" reloads the entire page, including header, sidebar, footer %>
<div class="user-profile">
  <h2><%= @user.name %></h2>
  <p><%= @user.bio %></p>
  <%= link_to "Edit Profile", edit_user_path(@user) %>
</div>

<div class="user-posts">
  <%= render @user.posts %>
</div>
```

**Correct (Turbo Frame scopes the edit interaction to the profile section):**

```erb
<%# app/views/users/show.html.erb %>
<%= turbo_frame_tag dom_id(@user, :profile) do %>
  <h2><%= @user.name %></h2>
  <p><%= @user.bio %></p>
  <%= link_to "Edit Profile", edit_user_path(@user) %>
<% end %>

<div class="user-posts">
  <%= render @user.posts %>
</div>
```

```erb
<%# app/views/users/edit.html.erb %>
<%# The response wraps the form in the SAME turbo-frame ID %>
<%= turbo_frame_tag dom_id(@user, :profile) do %>
  <%= form_with model: @user do |f| %>
    <%= f.text_field :name %>
    <%= f.text_area :bio %>
    <%= f.submit "Save" %>
  <% end %>
<% end %>
```

Clicking "Edit Profile" replaces only the profile frame with the edit form. The posts section, header, sidebar, and footer stay untouched. Submitting the form replaces the frame again with the updated show content.

### Lazy-Loading with Turbo Frames

Use `src` to lazily load frame content after the page renders:

```erb
<%# app/views/dashboards/show.html.erb %>
<h1>Dashboard</h1>

<%# Main content loads immediately %>
<%= render @recent_activity %>

<%# Sidebar loads asynchronously — doesn't block initial render %>
<%= turbo_frame_tag "sidebar_notifications", src: notifications_path, loading: :lazy do %>
  <p class="text-sm text-text-muted">Loading notifications...</p>
<% end %>
```

### When to Use Turbo Frames

| Scenario | Use Turbo Frame? |
|---|---|
| Inline edit/show toggle | Yes — classic use case |
| Tab content switching | Yes — each tab links to a frame |
| Lazy-loaded sidebar | Yes — `src` + `loading: :lazy` |
| Full-page navigation | No — let Turbo Drive handle it |
| Multi-element updates | No — use Turbo Streams instead |

Reference: [Turbo Frames Handbook](https://turbo.hotwired.dev/handbook/frames)
