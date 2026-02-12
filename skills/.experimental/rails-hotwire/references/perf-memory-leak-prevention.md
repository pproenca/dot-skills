---
title: Clean Up Subscriptions and Event Listeners
impact: MEDIUM
impactDescription: prevents 8MB memory accumulation per navigation
tags: perf, stimulus, memory, lifecycle
---

## Clean Up Subscriptions and Event Listeners

Stimulus controllers connect and disconnect as elements enter and leave the DOM during Turbo navigations. If `connect()` registers event listeners, creates timers, or opens ActionCable subscriptions without corresponding cleanup in `disconnect()`, those resources accumulate with each page visit. Over a session, this causes growing memory consumption, duplicate event handling, and degraded performance.

**Incorrect (addEventListener in connect() without removeEventListener in disconnect()):**

```js
// app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  connect() {
    // Leak: new subscription created on every connect, never removed
    createConsumer().subscriptions.create("NotificationChannel", {
      received: (data) => this.showNotification(data)
    })

    // Leak: anonymous function cannot be removed
    window.addEventListener("resize", () => {
      this.adjustLayout()
    })

    // Leak: interval never cleared
    setInterval(() => this.pollStatus(), 5000)
  }

  showNotification(data) {
    this.element.insertAdjacentHTML("beforeend",
      `<div class="notification">${data.message}</div>`)
  }

  adjustLayout() {
    this.element.style.width = `${window.innerWidth - 40}px`
  }

  pollStatus() {
    fetch("/notifications/unread_count")
      .then(r => r.json())
      .then(data => this.updateBadge(data.count))
  }
}
```

**Correct (proper cleanup in disconnect() for all manually added listeners):**

```js
// app/javascript/controllers/notification_controller.js
import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  connect() {
    this.cable = createConsumer()
    this.subscription = this.cable.subscriptions.create("NotificationChannel", {
      received: (data) => this.showNotification(data)
    })

    this.resizeHandler = this.adjustLayout.bind(this)
    window.addEventListener("resize", this.resizeHandler)

    this.pollTimer = setInterval(() => this.pollStatus(), 5000)
  }

  disconnect() {
    this.subscription?.unsubscribe()
    this.cable?.disconnect()

    window.removeEventListener("resize", this.resizeHandler)

    clearInterval(this.pollTimer)
  }

  showNotification(data) {
    this.element.insertAdjacentHTML("beforeend",
      `<div class="notification">${data.message}</div>`)
  }

  adjustLayout() {
    this.element.style.width = `${window.innerWidth - 40}px`
  }

  pollStatus() {
    fetch("/notifications/unread_count")
      .then(r => r.json())
      .then(data => this.updateBadge(data.count))
  }
}
```
