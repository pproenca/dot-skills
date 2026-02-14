---
title: Stimulus Controller Design Principles
impact: MEDIUM
impactDescription: average 50 lines per controller — 80% reduction in controller complexity
tags: view, stimulus, javascript, controllers, hotwire
---

## Stimulus Controller Design Principles

Fizzy's Stimulus controllers follow strict design rules: single responsibility, configuration via `static values` and `static classes`, private methods with `#` prefix, and inter-controller communication via `this.dispatch()`. Most controllers are under 50 lines. Build a library of generic, reusable controllers (copy-to-clipboard, hotkey, toggle-class, auto-resize) that compose together rather than building monolithic page controllers.

**Incorrect (monolithic controller with mixed concerns):**

```javascript
// app/javascript/controllers/card_controller.js — does too much
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "description", "counter", "copyButton", "menu"]

  connect() {
    this.resizeTextarea()
    this.startAutoSave()
    document.addEventListener("keydown", this.handleHotkey.bind(this))
  }

  disconnect() {
    clearInterval(this.autoSaveTimer)
    document.removeEventListener("keydown", this.handleHotkey.bind(this))
  }

  // Mixed: character counting + auto-resize + auto-save + clipboard + hotkeys
  count() {
    const len = this.descriptionTarget.value.length
    this.counterTarget.textContent = `${len}/500`
  }

  resizeTextarea() {
    this.descriptionTarget.style.height = "auto"
    this.descriptionTarget.style.height = this.descriptionTarget.scrollHeight + "px"
  }

  copy() {
    navigator.clipboard.writeText(window.location.href)
    this.copyButtonTarget.textContent = "Copied!"
    setTimeout(() => this.copyButtonTarget.textContent = "Copy link", 2000)
  }

  handleHotkey(event) {
    if (event.key === "e") this.titleTarget.focus()
  }

  startAutoSave() {
    this.autoSaveTimer = setInterval(() => this.save(), 30000)
  }

  save() { /* ... */ }
  toggleMenu() { this.menuTarget.classList.toggle("hidden") }
}
```

**Correct (small, composable, single-purpose controllers):**

```javascript
// app/javascript/controllers/autoresize_controller.js — 15 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  resize() {
    this.element.style.height = "auto"
    this.element.style.height = this.element.scrollHeight + "px"
  }

  connect() { this.resize() }
}

// app/javascript/controllers/copy_to_clipboard_controller.js — 20 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String }
  static classes = ["copied"]

  async copy() {
    await navigator.clipboard.writeText(this.contentValue)
    this.element.classList.add(this.copiedClass)
    setTimeout(() => this.element.classList.remove(this.copiedClass), 2000)
  }
}

// app/javascript/controllers/hotkey_controller.js — 25 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { key: String }

  connect() { document.addEventListener("keydown", this.#handleKey) }
  disconnect() { document.removeEventListener("keydown", this.#handleKey) }

  #handleKey = (event) => {
    if (event.key === this.keyValue && !this.#isTyping(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  #isTyping(event) {
    return ["INPUT", "TEXTAREA", "SELECT"].includes(event.target.tagName)
  }
}

// app/javascript/controllers/character_counter_controller.js — dispatches events
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  static values = { max: { type: Number, default: 500 } }

  count() {
    const length = this.inputTarget.value.length
    this.outputTarget.textContent = `${length}/${this.maxValue}`
    this.dispatch("counted", { detail: { length, exceeded: length > this.maxValue } })
  }
}
```

```html
<!-- Compose controllers in markup — each does one thing -->
<div data-controller="character-counter">
  <textarea
    data-controller="autoresize"
    data-character-counter-target="input"
    data-action="input->character-counter#count input->autoresize#resize"
  ></textarea>
  <span data-character-counter-target="output">0/500</span>
</div>

<button data-controller="copy-to-clipboard hotkey"
        data-copy-to-clipboard-content-value="<%= card_url(@card) %>"
        data-hotkey-key-value="c"
        data-action="click->copy-to-clipboard#copy">
  Copy link
</button>
```

**Design rules:**
- Single responsibility — one controller, one behavior
- Configuration via `static values` and `static classes`, not inline data attributes
- Private methods use `#` prefix (ES2022 private class fields)
- Inter-controller communication via `this.dispatch()` — never reach into other controllers
- Most controllers under 50 lines — if longer, it's doing too much

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
