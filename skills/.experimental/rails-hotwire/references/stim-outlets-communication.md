---
title: Use Outlets for Cross-Controller Communication
impact: MEDIUM-HIGH
impactDescription: eliminates brittle DOM queries and custom events between controllers
tags: stim, outlets, cross-controller, coordination
---

## Use Outlets for Cross-Controller Communication

When Stimulus controllers need to coordinate — a search controller filtering a results list, a modal controller closing from a form controller — the temptation is to use `document.querySelector` or dispatch custom DOM events. Outlets provide a declarative, testable way to reference other controller instances directly. Stimulus manages the lifecycle automatically: outlet callbacks fire when connected/disconnected, preventing stale references.

**Incorrect (querying the DOM or dispatching global events to coordinate controllers):**

```js
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  filter() {
    const query = this.element.querySelector("input").value

    // BAD: brittle DOM query to find the results controller
    const resultsEl = document.querySelector("[data-controller='results']")
    if (resultsEl) {
      // BAD: accessing another controller's internals
      const resultsController = this.application.getControllerForElementAndIdentifier(
        resultsEl, "results"
      )
      resultsController.updateFilter(query)
    }
  }
}
```

**Correct (outlets for declarative cross-controller references):**

```erb
<%# app/views/projects/index.html.erb %>
<div data-controller="search"
     data-search-results-outlet="#project-results">
  <%= form_with url: projects_path, method: :get,
      data: { action: "input->search#filter" } do |f| %>
    <%= f.search_field :q, value: params[:q] %>
  <% end %>
</div>

<div id="project-results"
     data-controller="results"
     data-results-url-value="<%= projects_path %>">
  <%= render @projects %>
</div>
```

```js
// app/javascript/controllers/search_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["results"]

  filter() {
    const query = this.element.querySelector("input").value
    // Outlet reference is managed by Stimulus — always current
    this.resultsOutlet.updateFilter(query)
  }

  // Optional: react when the results controller connects/disconnects
  resultsOutletConnected(outlet, element) {
    // Results are ready — enable the search input
    this.element.querySelector("input").disabled = false
  }
}
```

**When NOT to use this pattern:**
- For one-to-many communication (one controller to many listeners) — use Stimulus `dispatch` with custom events instead
- When controllers are on different pages — outlets only work within the same DOM tree

Reference: [Stimulus Reference — Outlets](https://stimulus.hotwired.dev/reference/outlets)
