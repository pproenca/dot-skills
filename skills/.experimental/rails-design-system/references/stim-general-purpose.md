---
title: Write General-Purpose Controllers, Not Page-Specific Ones
impact: MEDIUM
impactDescription: 10x fewer controllers — 5 reusable vs 50 one-off scripts
tags: stim, stimulus, reusability, naming
---

## Write General-Purpose Controllers, Not Page-Specific Ones

A controller named `dashboard-sidebar` can only be used on the dashboard sidebar. A controller named `toggle` can be used anywhere you need to show/hide content. Name controllers by behavior, not by the page they were first written for. This is the difference between 5 reusable controllers and 50 one-off scripts.

**Incorrect (page-specific controller that only works in one place):**

```javascript
// app/javascript/controllers/settings_page_toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["settingsPanel"]

  toggle() {
    this.settingsPanelTarget.classList.toggle("hidden")
  }
}
```

```erb
<%# Only usable on the settings page %>
<div data-controller="settings-page-toggle">
  <button data-action="settings-page-toggle#toggle">Show Settings</button>
  <div data-settings-page-toggle-target="settingsPanel" class="hidden">
    ...
  </div>
</div>
```

**Correct (generic toggle controller usable anywhere):**

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]
  static classes = ["toggle"]  // configurable via data attribute
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.sync()
  }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.sync()
  }

  sync() {
    const toggleClass = this.hasToggleClass ? this.toggleClass : "hidden"
    this.contentTargets.forEach(target => {
      target.classList.toggle(toggleClass, !this.openValue)
    })
  }
}
```

```erb
<%# Settings page sidebar %>
<div data-controller="toggle">
  <button data-action="toggle#toggle">Toggle Sidebar</button>
  <div data-toggle-target="content" class="hidden">...</div>
</div>

<%# FAQ accordion — same controller %>
<div data-controller="toggle">
  <button data-action="toggle#toggle">What is your return policy?</button>
  <div data-toggle-target="content" class="hidden">...</div>
</div>

<%# Mobile menu — same controller, different toggle class %>
<div data-controller="toggle" data-toggle-toggle-class="translate-x-full">
  <button data-action="toggle#toggle">Menu</button>
  <nav data-toggle-target="content" class="translate-x-full">...</nav>
</div>

<%# Start open %>
<div data-controller="toggle" data-toggle-open-value="true">
  <button data-action="toggle#toggle">Collapse Details</button>
  <div data-toggle-target="content">Visible by default</div>
</div>
```

Good general-purpose controller names: `toggle`, `clipboard`, `dropdown`, `modal`, `autosave`, `countdown`, `char-count`, `filter`, `sortable`, `tabs`.

Bad page-specific controller names: `dashboard-sidebar`, `settings-form`, `user-profile-tabs`, `checkout-payment`.

Reference: [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
