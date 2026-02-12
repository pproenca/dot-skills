---
title: Configure Controllers via Data Attributes, Not Hardcoded Values
impact: MEDIUM
impactDescription: enables one controller to serve many contexts
tags: stim, stimulus, values, classes, configuration
---

## Configure Controllers via Data Attributes, Not Hardcoded Values

Hardcoding CSS classes, URLs, or thresholds in Stimulus controllers makes them single-purpose. The Stimulus Values and Classes APIs let you configure behavior from HTML, keeping the JavaScript generic and the HTML contextual. One controller, many configurations.

**Incorrect (hardcoded values in the controller):**

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    // Hardcoded class — can't change without editing JS
    this.menuTarget.classList.toggle("hidden")
  }

  select(event) {
    // Hardcoded URL — only works for one endpoint
    fetch("/api/users/search", {
      method: "POST",
      body: JSON.stringify({ query: event.target.value })
    })
  }

  connect() {
    // Hardcoded delay — can't adjust per-usage
    this.timeout = setTimeout(() => this.close(), 5000)
  }
}
```

**Correct (configurable via Stimulus Values and Classes APIs):**

```javascript
// app/javascript/controllers/dropdown_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]
  static classes = ["toggle", "active"]
  static values = {
    url: String,                              // Required string value
    delay: { type: Number, default: 300 },    // Optional with default
    closeOnSelect: { type: Boolean, default: true },
    placement: { type: String, default: "bottom" }
  }

  toggle() {
    const toggleClass = this.hasToggleClass ? this.toggleClass : "hidden"
    this.menuTarget.classList.toggle(toggleClass)

    if (this.hasActiveClass) {
      this.buttonTarget.classList.toggle(this.activeClass)
    }
  }

  async search(event) {
    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ query: event.target.value })
    })
    // ...
  }

  connect() {
    this.autoCloseTimer = setTimeout(() => this.close(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.autoCloseTimer)
  }
}
```

```erb
<%# User search dropdown — searches users API %>
<div data-controller="dropdown"
     data-dropdown-url-value="/api/users/search"
     data-dropdown-delay-value="500"
     data-dropdown-toggle-class="hidden"
     data-dropdown-active-class="bg-gray-100">
  <button data-dropdown-target="button"
          data-action="dropdown#toggle">
    Search Users
  </button>
  <div data-dropdown-target="menu" class="hidden">...</div>
</div>

<%# Product filter dropdown — different URL, different delay %>
<div data-controller="dropdown"
     data-dropdown-url-value="/api/products/filter"
     data-dropdown-delay-value="200"
     data-dropdown-close-on-select-value="false"
     data-dropdown-toggle-class="opacity-0 scale-95">
  <button data-dropdown-target="button"
          data-action="dropdown#toggle">
    Filter Products
  </button>
  <div data-dropdown-target="menu" class="opacity-0 scale-95 transition-all">...</div>
</div>
```

The Values API provides automatic type coercion, default values, and change callbacks:

```javascript
static values = {
  count: { type: Number, default: 0 },
  label: { type: String, default: "items" }
}

// Stimulus auto-generates a change callback
countValueChanged(newCount, oldCount) {
  this.element.textContent = `${newCount} ${this.labelValue}`
}
```

Reference: [Stimulus Values](https://stimulus.hotwired.dev/reference/values)
