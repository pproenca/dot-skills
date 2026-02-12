---
title: Use Stimulus Only for Client-Side Behavior
impact: MEDIUM
impactDescription: prevents Stimulus from becoming a SPA framework
tags: arch, stimulus, separation-of-concerns, controllers
---

## Use Stimulus Only for Client-Side Behavior

Stimulus is designed for small, reusable behaviors that enhance server-rendered HTML: toggling visibility, copying to clipboard, counting characters, managing dropdowns. When a Stimulus controller starts fetching data, constructing DOM from templates, managing navigation, or orchestrating complex state machines, it has outgrown its purpose. Those responsibilities belong to Turbo Frames, Turbo Streams, or the server. Keep controllers small, focused, and portable.

**Incorrect (Stimulus controller that fetches data, builds HTML, and manages complex state):**

```js
// app/javascript/controllers/task_board_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { tasks: Array, currentFilter: String, sortOrder: String }

  async connect() {
    const response = await fetch("/api/tasks")
    this.tasksValue = await response.json()
    this.render()
  }

  render() {
    const filtered = this.tasksValue
      .filter(t => this.currentFilterValue === "all" || t.status === this.currentFilterValue)
      .sort((a, b) => this.sortOrderValue === "asc" ? a.priority - b.priority : b.priority - a.priority)

    this.element.innerHTML = `
      <div class="columns">
        ${["todo", "in_progress", "done"].map(status => `
          <div class="column" data-status="${status}">
            <h3>${status}</h3>
            ${filtered.filter(t => t.status === status).map(t => `
              <div class="task-card" draggable="true" data-id="${t.id}">
                <h4>${t.title}</h4>
                <p>${t.assignee}</p>
              </div>
            `).join("")}
          </div>
        `).join("")}
      </div>
    `
  }
}
```

**Correct (Stimulus for toggling visibility, Turbo Frame for loading content from server):**

```erb
<%# Server renders the board — Turbo Frame handles loading/filtering %>
<%= form_with url: project_tasks_path(@project), method: :get,
    data: { turbo_frame: "task_board" } do |f| %>
  <%= f.select :filter, ["All", "To Do", "In Progress", "Done"],
      data: { action: "change->form#requestSubmit" } %>
<% end %>

<turbo-frame id="task_board">
  <div class="columns">
    <% %w[todo in_progress done].each do |status| %>
      <div class="column">
        <h3><%= status.titleize %></h3>
        <%= render @tasks.select { |t| t.status == status } %>
      </div>
    <% end %>
  </div>
</turbo-frame>
```

```js
// Stimulus only handles pure client-side behavior
// app/javascript/controllers/character_count_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = { max: { type: Number, default: 280 } }

  count() {
    const remaining = this.maxValue - this.inputTarget.value.length
    this.counterTarget.textContent = `${remaining} characters remaining`
    this.counterTarget.classList.toggle("text-red-600", remaining < 0)
  }
}
```
