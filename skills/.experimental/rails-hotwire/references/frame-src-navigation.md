---
title: Use src for Dynamic Frame Content
impact: HIGH
impactDescription: eliminates custom JavaScript for content loading
tags: frame, src, dynamic, content-loading
---

## Use src for Dynamic Frame Content

Turbo Frames with a `src` attribute automatically fetch and render remote content, replacing the need for custom JavaScript `fetch()` + DOM manipulation. Changing the `src` attribute on a frame programmatically reloads it with new content. This pattern is ideal for tabs, paginated lists, and any section that loads content from a different endpoint.

**Incorrect (JavaScript fetch + innerHTML to update a section):**

```erb
<%# app/views/projects/show.html.erb %>
<div class="tabs">
  <button onclick="loadTab('overview')">Overview</button>
  <button onclick="loadTab('members')">Members</button>
  <button onclick="loadTab('settings')">Settings</button>
</div>

<div id="tab-content">
  <%# Content loaded via JavaScript %>
</div>

<script>
  async function loadTab(tab) {
    const response = await fetch(`/projects/<%= @project.id %>/${tab}`);
    const html = await response.text();
    document.getElementById("tab-content").innerHTML = html;
  }
  loadTab("overview");
</script>
```

**Correct (Turbo Frame with src for remote content loading):**

```erb
<%# app/views/projects/show.html.erb %>
<div class="tabs">
  <%= link_to "Overview",
      project_overview_path(@project),
      data: { turbo_frame: "tab_content" } %>
  <%= link_to "Members",
      project_members_path(@project),
      data: { turbo_frame: "tab_content" } %>
  <%= link_to "Settings",
      project_settings_path(@project),
      data: { turbo_frame: "tab_content" } %>
</div>

<%# Frame loads its src on page load, tabs swap the content %>
<%= turbo_frame_tag "tab_content",
    src: project_overview_path(@project) do %>
  <p>Loading...</p>
<% end %>
```

```erb
<%# app/views/projects/overview.html.erb %>
<%= turbo_frame_tag "tab_content" do %>
  <div class="overview">
    <h2>Project Overview</h2>
    <p><%= @project.description %></p>
  </div>
<% end %>
```
