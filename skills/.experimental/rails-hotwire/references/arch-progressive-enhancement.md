---
title: Follow the Progressive Enhancement Hierarchy
impact: MEDIUM
impactDescription: prevents over-engineering with unnecessary JavaScript
tags: arch, progressive-enhancement, turbo, stimulus
---

## Follow the Progressive Enhancement Hierarchy

Hotwire provides a layered toolkit where each layer adds capability at the cost of complexity. Starting with the simplest tool that solves the problem keeps the codebase maintainable, reduces JavaScript surface area, and ensures graceful degradation. The hierarchy is: plain HTML and CSS first, then Turbo Drive, then Turbo Frames, then Turbo Streams, and only reach for Stimulus when genuine client-side behavior is needed.

**Incorrect (reaching for Turbo Frames when plain HTML or Stimulus would suffice):**

```erb
<%# app/views/projects/show.html.erb %>
<%# BAD: Using a Turbo Frame round-trip just to show/hide static content
    that's already on the page. This adds unnecessary server requests. %>
<%= turbo_frame_tag "project_details",
    src: project_details_path(@project) do %>
  <p>Loading details...</p>
<% end %>

<%# Or worse: using Turbo Streams to toggle visibility %>
<%= button_to "Show Details", toggle_project_details_path(@project),
    method: :post %>
```

```ruby
# app/controllers/projects_controller.rb
# BAD: server endpoint just to toggle visibility of static content
def toggle_details
  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace("project_details",
        partial: "projects/details", locals: { project: @project })
    end
  end
end
```

**Correct (using the simplest tool: HTML first, then CSS, then Stimulus, then Turbo):**

```erb
<%# Step 1: Pure HTML — no JavaScript needed for a simple disclosure %>
<details>
  <summary>Show Details</summary>
  <p><%= @project.description %></p>
  <p>Created: <%= @project.created_at.to_fs(:long) %></p>
</details>

<%# Step 2: If content is expensive to load, use a Turbo Frame %>
<details>
  <summary>Show Team Members</summary>
  <turbo-frame id="team_members" src="<%= project_team_members_path(@project) %>" loading="lazy">
    <p>Loading...</p>
  </turbo-frame>
</details>

<%# Step 3: Only use Stimulus when you need behavior CSS/HTML can't provide,
    such as copying to clipboard or tracking character count %>
<div data-controller="clipboard">
  <input type="text" value="<%= project_url(@project) %>" readonly data-clipboard-target="source">
  <button data-action="click->clipboard#copy">Copy Link</button>
</div>
```
