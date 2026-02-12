---
title: Use Values API for Reactive Controller State
impact: MEDIUM-HIGH
impactDescription: eliminates manual DOM parsing and enables automatic morph compatibility
tags: stim, values, state, reactive
---

## Use Values API for Reactive Controller State

Stimulus Values let you declare typed state on a controller element via `data-*-value` attributes. When a value changes — whether from JavaScript or from Turbo morphing the DOM — Stimulus fires a `{name}ValueChanged` callback automatically. This replaces manual `getAttribute` calls, keeps state in HTML (the single source of truth), and ensures controllers re-initialize correctly after morph.

**Incorrect (reading state from DOM attributes manually, missing morph updates):**

```js
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // BAD: manual attribute parsing — no type safety, no change detection
    this.deadline = new Date(this.element.dataset.deadline)
    this.warningThreshold = parseInt(this.element.dataset.warningMinutes) || 5
    this.start()
  }

  start() {
    this.timer = setInterval(() => {
      const remaining = this.deadline - new Date()
      this.element.textContent = this.format(remaining)
      // BAD: if Turbo morph changes data-deadline, this still uses the old value
    }, 1000)
  }
}
```

**Correct (Values API with typed defaults and change callbacks):**

```js
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    deadline: String,
    warningMinutes: { type: Number, default: 5 }
  }

  connect() {
    this.start()
  }

  disconnect() {
    clearInterval(this.timer)
  }

  // Fires automatically when data-countdown-deadline-value changes
  // — including after Turbo morph updates the attribute
  deadlineValueChanged() {
    clearInterval(this.timer)
    this.start()
  }

  start() {
    this.timer = setInterval(() => {
      const remaining = new Date(this.deadlineValue) - new Date()
      this.element.textContent = this.format(remaining)
      this.element.classList.toggle(
        "text-red-600",
        remaining < this.warningMinutesValue * 60000
      )
    }, 1000)
  }

  format(ms) {
    const minutes = Math.floor(ms / 60000)
    const seconds = Math.floor(ms / 1000) % 60
    return `${minutes}:${seconds.toString().padStart(2, "0")}`
  }
}
```

```erb
<%# Values are set via data attributes — HTML is the source of truth %>
<span data-controller="countdown"
      data-countdown-deadline-value="<%= @auction.ends_at.iso8601 %>"
      data-countdown-warning-minutes-value="10">
</span>
```

Reference: [Stimulus Reference — Values](https://stimulus.hotwired.dev/reference/values)
