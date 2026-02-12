---
title: Handle Stimulus Controller Reconnection After Morph
impact: MEDIUM-HIGH
impactDescription: "prevents broken interactivity after morphing updates"
tags: morph, stimulus, controllers, lifecycle
---

## Handle Stimulus Controller Reconnection After Morph

When Turbo morphs the DOM, it patches elements in place rather than removing and re-inserting them. This means Stimulus controllers attached to morphed elements may not receive `disconnect`/`connect` lifecycle callbacks, leaving stale state (expired timers, orphaned event listeners, outdated data).

**Decision tree for morph handling:**
1. **If your state is in Stimulus values** (data attributes): use `valueChanged` callbacks — Stimulus detects attribute changes from morphing automatically.
2. **If your state is NOT in values** (timers, third-party library instances, manual event listeners): listen to `turbo:morph-element` to detect when your element has been patched and re-initialize.

**Incorrect (Stimulus controller state lost after morph):**

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { deadline: String };

  connect() {
    this.startCountdown();
  }

  disconnect() {
    clearInterval(this.timer);
  }

  startCountdown() {
    this.timer = setInterval(() => {
      const remaining = new Date(this.deadlineValue) - new Date();
      this.element.textContent = this.formatTime(remaining);
    }, 1000);
  }

  // BUG: when morph updates the deadline value attribute,
  // the controller keeps counting down to the OLD deadline
  // because connect/disconnect are never called.

  formatTime(ms) {
    const seconds = Math.floor(ms / 1000) % 60;
    const minutes = Math.floor(ms / 60000);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  }
}
```

**Correct (valueChanged callback for value-based state, turbo:morph-element for non-value state):**

Approach 1 — valueChanged callback (preferred when state is in values):

```javascript
// app/javascript/controllers/countdown_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { deadline: String };

  connect() {
    this.startCountdown();
  }

  disconnect() {
    clearInterval(this.timer);
  }

  // Stimulus fires this when the data-countdown-deadline-value attribute
  // changes — including when Turbo morphs new attribute values onto the element
  deadlineValueChanged() {
    clearInterval(this.timer);
    this.startCountdown();
  }

  startCountdown() {
    this.timer = setInterval(() => {
      const remaining = new Date(this.deadlineValue) - new Date();
      this.element.textContent = this.formatTime(remaining);
    }, 1000);
  }

  formatTime(ms) {
    const seconds = Math.floor(ms / 1000) % 60;
    const minutes = Math.floor(ms / 60000);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  }
}
```

Approach 2 — turbo:morph-element (for state not captured in values):

```javascript
// app/javascript/controllers/chart_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { endpoint: String };

  connect() {
    // Third-party library instance — not stored in Stimulus values
    this.chart = new ChartLibrary(this.element, { endpoint: this.endpointValue });
    this.element.addEventListener("turbo:morph-element", this.handleMorph);
  }

  disconnect() {
    this.chart.destroy();
    this.element.removeEventListener("turbo:morph-element", this.handleMorph);
  }

  handleMorph = () => {
    // Re-initialize the chart with new DOM state after morph
    this.chart.destroy();
    this.chart = new ChartLibrary(this.element, { endpoint: this.endpointValue });
  };
}
```
