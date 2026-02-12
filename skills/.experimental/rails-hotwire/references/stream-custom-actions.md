---
title: Register Custom Stream Actions for Complex DOM Updates
impact: MEDIUM
impactDescription: "eliminates custom JavaScript for non-standard mutations"
tags: stream, custom-actions, extensibility, dom-manipulation
---

## Register Custom Stream Actions for Complex DOM Updates

The built-in nine stream actions cover most DOM mutations, but application-specific behaviors like showing a toast notification, updating a chart, or triggering a CSS animation require custom logic. Registering a custom action with `Turbo.StreamActions` keeps this logic declarative and delivered via the same stream pipeline, eliminating ad-hoc JavaScript event listeners that bypass Turbo's lifecycle.

**Incorrect (JavaScript event listeners doing DOM manipulation after stream delivery):**

```javascript
// app/javascript/application.js
// BAD: manual listener that duplicates stream delivery logic
document.addEventListener("turbo:before-stream-render", (event) => {
  const stream = event.target;
  if (stream.querySelector("template").content.textContent.includes("flash:")) {
    event.preventDefault();
    const message = stream.querySelector("template").content.textContent.replace("flash:", "");
    showToast(message);
  }
});

function showToast(message) {
  const toast = document.createElement("div");
  toast.className = "toast toast-success";
  toast.textContent = message;
  document.getElementById("toast-container").appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
}
```

**Correct (custom StreamAction registered with Turbo.StreamActions):**

```javascript
// app/javascript/custom_stream_actions.js
import { Turbo } from "@hotwired/turbo-rails";

// Register a custom "toast" action
Turbo.StreamActions.toast = function () {
  const message = this.templateContent.textContent.trim();
  const level = this.getAttribute("level") || "info";

  const toast = document.createElement("div");
  toast.className = `toast toast-${level}`;
  toast.textContent = message;
  document.getElementById("toast-container").appendChild(toast);
  setTimeout(() => toast.remove(), 3000);
};
```

```erb
<%# app/views/messages/create.turbo_stream.erb %>
<%= turbo_stream.append "messages", partial: "messages/message", locals: { message: @message } %>

<%# Trigger the custom toast action %>
<turbo-stream action="toast" level="success">
  <template>Message sent successfully</template>
</turbo-stream>
```
