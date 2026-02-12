---
title: Follow the Progressive Enhancement Hierarchy
impact: MEDIUM
impactDescription: prevents over-engineering with unnecessary JavaScript
tags: arch, progressive-enhancement, turbo, stimulus
---

## Follow the Progressive Enhancement Hierarchy

Hotwire provides a layered toolkit where each layer adds capability at the cost of complexity. Starting with the simplest tool that solves the problem keeps the codebase maintainable, reduces JavaScript surface area, and ensures graceful degradation. The hierarchy is: plain HTML and CSS first, then Turbo Drive, then Turbo Frames, then Turbo Streams, and only reach for Stimulus when genuine client-side behavior is needed.

**Incorrect (reaching for Stimulus + custom JavaScript for a toggle that CSS can handle):**

```erb
<%# app/views/projects/show.html.erb %>
<div data-controller="toggle">
  <button data-action="click->toggle#toggle">Show Details</button>
  <div data-toggle-target="content" class="hidden">
    <p><%= @project.description %></p>
    <p>Created: <%= @project.created_at.to_fs(:long) %></p>
  </div>
</div>
```

```js
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

**Correct (using HTML details/summary, then Turbo Frame, then Stimulus only if needed):**

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
