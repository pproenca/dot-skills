---
title: Implement Optimistic UI Updates Before Server Confirmation
impact: MEDIUM-HIGH
impactDescription: 0ms perceived feedback vs 260ms traditional flow
tags: perf, turbo-streams, stimulus, ux
---

## Implement Optimistic UI Updates Before Server Confirmation

Users perceive applications as slow when they must wait for a full server round-trip before seeing any visual feedback. Optimistic UI immediately reflects the expected outcome on the client, then lets Turbo Morph confirm or correct the state when the server responds. This dramatically improves perceived performance on actions with predictable outcomes like sending messages or toggling favorites.

**Incorrect (waiting for full server round-trip before showing any UI change):**

```erb
<!-- app/views/messages/_form.html.erb -->
<%= form_with model: [project, Message.new], data: { turbo_stream: true } do |f| %>
  <%= f.text_area :body %>
  <%= f.submit "Send", class: "btn" %>
<% end %>

<!-- User clicks Send, sees nothing for 260ms until server responds -->
<!-- No visual feedback during the wait -->
```

**Correct (Stimulus controller adds optimistic element, server morph validates):**

```erb
<!-- app/views/messages/_form.html.erb -->
<%= form_with model: [project, Message.new],
    data: {
      turbo_stream: true,
      controller: "optimistic-message",
      action: "turbo:submit-start->optimistic-message#add turbo:submit-end->optimistic-message#resolve"
    } do |f| %>
  <%= f.text_area :body, data: { optimistic_message_target: "input" } %>
  <%= f.submit "Send", class: "btn" %>
<% end %>
```

```js
// app/javascript/controllers/optimistic_message_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  add(event) {
    const body = this.inputTarget.value
    if (!body.trim()) return

    const messages = document.getElementById("messages")
    const optimistic = document.createElement("div")
    optimistic.classList.add("message", "message--optimistic")
    optimistic.textContent = body
    optimistic.dataset.optimistic = "true"
    messages.appendChild(optimistic)

    this.inputTarget.value = ""
  }

  resolve() {
    // Server morph replaces optimistic element with real one
    document.querySelectorAll("[data-optimistic='true']").forEach(el => el.remove())
  }
}
```
