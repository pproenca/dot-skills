---
title: Coordinate Turbo and Stimulus Without Conflicts
impact: MEDIUM-HIGH
impactDescription: prevents controller disconnection bugs after Turbo navigation
tags: turbo, stimulus, coordination, lifecycle
---

## Coordinate Turbo and Stimulus Without Conflicts

Turbo replaces DOM elements during navigation, frame updates, and stream actions. Stimulus controllers attached to replaced elements disconnect and reconnect. If your controller sets up event listeners on `window` or `document` in `connect()`, failing to clean them up in `disconnect()` causes memory leaks and duplicate handlers after Turbo navigations.

**Incorrect (event listener leak after Turbo navigation):**

```javascript
// app/javascript/controllers/scroll_spy_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // This listener is never removed when Turbo replaces the page
    window.addEventListener("scroll", this.onScroll.bind(this))
  }

  onScroll() {
    // After 3 Turbo navigations, this fires 3 times per scroll event
    this.highlightCurrentSection()
  }
}
```

**Correct (clean up in disconnect, use bound references):**

```javascript
// app/javascript/controllers/scroll_spy_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundOnScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.boundOnScroll)
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundOnScroll)
  }

  onScroll() {
    this.highlightCurrentSection()
  }
}
```

### Turbo Events for Stimulus

Use Turbo lifecycle events when you need to respond to navigation:

```javascript
// app/javascript/controllers/analytics_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundTrackPage = this.trackPage.bind(this)
    document.addEventListener("turbo:load", this.boundTrackPage)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.boundTrackPage)
  }

  trackPage() {
    // Fires after every Turbo Drive navigation (including initial page load)
    analytics.track("page_view", { url: window.location.href })
  }
}
```

### Key Turbo Events

| Event | When it fires |
|---|---|
| `turbo:load` | After initial page load AND every Turbo Drive visit |
| `turbo:before-visit` | Before Turbo Drive navigates (cancel with `event.preventDefault()`) |
| `turbo:frame-load` | After a Turbo Frame loads its content |
| `turbo:before-stream-render` | Before a Turbo Stream action is applied |
| `turbo:submit-start` | When a Turbo form submission begins |
| `turbo:submit-end` | When a Turbo form submission completes |

### Stimulus Lifecycle with Turbo

```text
Initial page load:     connect()
Turbo Drive visit:     disconnect() → (new page) → connect()
Turbo Frame update:    disconnect() (old frame) → connect() (new frame)
Turbo Stream append:   connect() (new element only)
Turbo Stream remove:   disconnect() (removed element)
Turbo Stream replace:  disconnect() (old) → connect() (new)
```

Store all state in Stimulus Values (in the DOM) rather than in JavaScript instance variables. When Turbo replaces an element, Values are preserved in the new HTML and the controller re-reads them on `connect()`.

Reference: [Turbo Events Reference](https://turbo.hotwired.dev/reference/events)
