---
title: Keep State on the Server, Not the Client
impact: MEDIUM
impactDescription: eliminates client-server state synchronization bugs
tags: arch, state-management, turbo, server-rendering
---

## Keep State on the Server, Not the Client

Hotwire's core principle is that the server renders HTML and Turbo delivers it to the browser. When Stimulus controllers start fetching JSON, building HTML client-side, or managing complex application state in JavaScript values, you recreate the synchronization problems that Hotwire was designed to eliminate. Server-rendered HTML delivered via Frames or Streams is the single source of truth, and Stimulus should only manage ephemeral UI state like open/closed toggles.

**Incorrect (Stimulus controller fetching JSON API and rendering HTML client-side):**

```js
// app/javascript/controllers/project_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { projects: Array, page: Number, filter: String }

  connect() {
    this.loadProjects()
  }

  async loadProjects() {
    const response = await fetch(`/api/projects?page=${this.pageValue}&filter=${this.filterValue}`)
    const data = await response.json()
    this.projectsValue = data.projects

    // Building HTML in JavaScript — defeats the purpose of Hotwire
    this.element.innerHTML = this.projectsValue.map(project => `
      <div class="project-card">
        <h3>${project.name}</h3>
        <p>${project.description}</p>
        <span class="badge">${project.status}</span>
      </div>
    `).join("")
  }

  filter(event) {
    this.filterValue = event.target.value
    this.loadProjects()
  }
}
```

**Correct (server renders HTML partial, Turbo Frame or Stream delivers it):**

```erb
<%# app/views/projects/index.html.erb %>
<%= form_with url: projects_path, method: :get,
    data: { turbo_frame: "project_list", turbo_action: "advance" } do |f| %>
  <%= f.select :filter, ["All", "Active", "Archived"],
      selected: params[:filter] || "All" ,
      data: { action: "change->form#requestSubmit" } %>
<% end %>

<turbo-frame id="project_list">
  <%= render @projects %>

  <%== pagy_nav(@pagy) %>
</turbo-frame>
```

```ruby
# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  def index
    @projects = Project.filter_by(params[:filter]).page(params[:page])
    # Rails automatically renders HTML — no JSON API needed
    # Turbo Frame scopes the response to just the project list
  end
end
```
