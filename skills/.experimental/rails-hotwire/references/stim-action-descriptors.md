---
title: Use Declarative Action Descriptors Over addEventListener
impact: MEDIUM
impactDescription: eliminates manual event wiring and memory leak risk
tags: stim, actions, events, declarative
---

## Use Declarative Action Descriptors Over addEventListener

Stimulus action descriptors (`data-action="event->controller#method"`) declaratively bind events to controller methods in HTML. Stimulus manages listener lifecycle automatically — adding on `connect` and removing on `disconnect`. Manual `addEventListener` calls in `connect()` require matching `removeEventListener` in `disconnect()` with bound function references, which is a common source of memory leaks in Turbo-navigated applications.

**Incorrect (manual addEventListener in connect, easy to forget cleanup):**

```js
// app/javascript/controllers/keyboard_shortcut_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // BAD: manual listener requires manual cleanup
    this.handleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.handleKeydown)

    this.element.querySelector(".search-input")
      .addEventListener("input", (e) => this.search(e))

    this.element.querySelector(".clear-btn")
      .addEventListener("click", () => this.clear())
  }

  disconnect() {
    // Easy to forget, or to miss one of the listeners
    document.removeEventListener("keydown", this.handleKeydown)
    // The anonymous functions above can never be removed — memory leak
  }
}
```

**Correct (data-action descriptors handle lifecycle automatically):**

```erb
<div data-controller="keyboard-shortcut"
     data-action="keydown@document->keyboard-shortcut#handleKeydown">
  <input type="search"
         class="search-input"
         data-action="input->keyboard-shortcut#search">
  <button class="clear-btn"
          data-action="click->keyboard-shortcut#clear">
    Clear
  </button>
</div>
```

```js
// app/javascript/controllers/keyboard_shortcut_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // No connect/disconnect needed — Stimulus manages all listeners

  handleKeydown(event) {
    if (event.key === "/" && !event.metaKey) {
      event.preventDefault()
      this.element.querySelector(".search-input").focus()
    }
  }

  search(event) {
    // Turbo Frame handles the actual filtering
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      event.target.form.requestSubmit()
    }, 300)
  }

  clear() {
    this.element.querySelector(".search-input").value = ""
    this.search({ target: this.element.querySelector(".search-input") })
  }
}
```

**When NOT to use this pattern:**
- For events on elements created dynamically after `connect()` — use event delegation on a parent target instead
- For third-party library callbacks that don't fire DOM events — manual wiring in `connect()` with cleanup in `disconnect()` is required

Reference: [Stimulus Reference — Actions](https://stimulus.hotwired.dev/reference/actions)
