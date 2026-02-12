---
title: Handle Turbo Navigation and Fetch Errors Gracefully
impact: HIGH
impactDescription: prevents blank screens and silent failures on server errors
tags: drive, error-handling, resilience, events
---

## Handle Turbo Navigation and Fetch Errors Gracefully

When Turbo Drive encounters a server error (500), network failure, or timeout, it either shows the raw error response or silently fails. When a Turbo Frame request fails, the frame goes blank with no feedback. Turbo emits events at each failure point (`turbo:fetch-request-error`, `turbo:frame-missing`, `turbo:frame-render`) that let you intercept errors and show meaningful feedback instead of leaving users staring at a broken page.

**Incorrect (no error handling — server errors show raw HTML or blank frames):**

```erb
<%# app/views/projects/show.html.erb %>
<%# If this frame's endpoint returns 500, the frame goes blank silently %>
<%= turbo_frame_tag "project_comments",
    src: project_comments_path(@project),
    loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>

<%# No error handling configured — a network failure during Drive navigation
    shows a blank page or the browser's default error %>
```

**Correct (event listeners for error recovery and user feedback):**

```js
// app/javascript/turbo_error_handler.js
// Handle network errors during Turbo Drive navigation
document.addEventListener("turbo:fetch-request-error", (event) => {
  event.preventDefault()
  const message = navigator.onLine
    ? "Something went wrong. Please try again."
    : "You appear to be offline. Check your connection."
  showFlash(message, "error")
})

// Handle missing frame content (frame response doesn't contain matching frame)
document.addEventListener("turbo:frame-missing", (event) => {
  event.preventDefault()
  const frame = event.target
  frame.innerHTML = `
    <div class="frame-error" role="alert">
      <p>This content could not be loaded.</p>
      <button onclick="this.closest('turbo-frame').reload()">Retry</button>
    </div>
  `
})

function showFlash(message, level) {
  const flash = document.createElement("div")
  flash.className = `flash flash-${level}`
  flash.setAttribute("role", "alert")
  flash.textContent = message
  document.querySelector(".flash-messages")?.appendChild(flash)
  setTimeout(() => flash.remove(), 5000)
}
```

```erb
<%# app/views/layouts/application.html.erb %>
<%= javascript_importmap_tags %>

<div class="flash-messages" data-turbo-temporary>
  <%# Flash container for both server and client-side messages %>
</div>

<%= yield %>
```

**When NOT to use this pattern:**
- For API-only endpoints that don't serve HTML — use standard HTTP error handling
- In development mode where you want to see full error pages for debugging

Reference: [Turbo Reference — Events](https://turbo.hotwired.dev/reference/events)
