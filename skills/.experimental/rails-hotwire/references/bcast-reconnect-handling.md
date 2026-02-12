---
title: Handle WebSocket Disconnection and Reconnection
impact: HIGH
impactDescription: prevents stale UI when users lose and regain connectivity
tags: bcast, websocket, reconnection, resilience
---

## Handle WebSocket Disconnection and Reconnection

ActionCable reconnects automatically after a WebSocket disconnection, but any broadcasts sent during the downtime are lost — the client never receives them. After reconnection, the page displays stale data until the next broadcast or manual refresh. Detecting disconnection state and triggering a page refresh on reconnection ensures users always see current data.

**Incorrect (no awareness of WebSocket state — stale data after reconnection):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from @project %>

<div id="tasks">
  <%= render @project.tasks %>
</div>

<%# If the user's Wi-Fi drops for 30 seconds and 3 tasks are created,
    those broadcasts are lost. After reconnection the user sees
    the old task list until someone creates yet another task. %>
```

**Correct (Stimulus controller monitors cable state and refreshes on reconnection):**

```erb
<%# app/views/projects/show.html.erb %>
<%= turbo_stream_from @project %>

<div data-controller="cable-monitor"
     data-cable-monitor-stale-class="border-yellow-400">
  <div id="tasks">
    <%= render @project.tasks %>
  </div>
</div>
```

```js
// app/javascript/controllers/cable_monitor_controller.js
import { Controller } from "@hotwired/stimulus"
import { getConsumer } from "@hotwired/turbo-rails"

export default class extends Controller {
  static classes = ["stale"]

  connect() {
    this.monitor = getConsumer().connection.monitor
    this.checkInterval = setInterval(() => this.checkConnection(), 2000)
    this.wasDisconnected = false
  }

  disconnect() {
    clearInterval(this.checkInterval)
  }

  checkConnection() {
    const connected = this.monitor.isRunning()

    if (!connected && !this.wasDisconnected) {
      this.wasDisconnected = true
      this.element.classList.add(...this.staleClasses)
    }

    if (connected && this.wasDisconnected) {
      this.wasDisconnected = false
      this.element.classList.remove(...this.staleClasses)
      // Refresh the page to catch up on missed broadcasts
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }
}
```

**When NOT to use this pattern:**
- On pages without real-time broadcasts — the overhead of monitoring is unnecessary
- When using `broadcasts_refreshes` with frequent updates — the next broadcast will naturally catch up

Reference: [ActionCable Connection Monitor — Rails](https://github.com/rails/rails/blob/main/actioncable/app/javascript/action_cable/connection_monitor.js)
