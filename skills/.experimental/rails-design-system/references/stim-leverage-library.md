---
title: Use stimulus-components Before Writing Custom Controllers
impact: LOW-MEDIUM
impactDescription: avoids reinventing common UI behaviors
tags: stim, stimulus, libraries, reuse
---

## Use stimulus-components Before Writing Custom Controllers

Before writing a Stimulus controller from scratch, check if one already exists in the stimulus-components ecosystem. These are production-tested, well-documented controllers for common UI patterns like clipboard, dropdown, sortable lists, tabs, and more. Writing your own version of a solved problem wastes time and introduces bugs.

**Incorrect (writing a custom clipboard controller from scratch):**

```javascript
// app/javascript/controllers/clipboard_controller.js — reinventing the wheel
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    try {
      navigator.clipboard.writeText(this.sourceTarget.value || this.sourceTarget.textContent)
      const originalText = this.buttonTarget.textContent
      this.buttonTarget.textContent = "Copied!"
      setTimeout(() => {
        this.buttonTarget.textContent = originalText
      }, 2000)
    } catch (err) {
      // Fallback for older browsers
      const textarea = document.createElement("textarea")
      textarea.value = this.sourceTarget.value || this.sourceTarget.textContent
      document.body.appendChild(textarea)
      textarea.select()
      document.execCommand("copy")
      document.body.removeChild(textarea)
    }
  }
}
```

**Correct (using stimulus-clipboard from stimulus-components):**

```bash
yarn add @stimulus-components/clipboard
```

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"
import Clipboard from "@stimulus-components/clipboard"

application.register("clipboard", Clipboard)
```

```erb
<div data-controller="clipboard">
  <input type="text" value="https://myapp.com/invite/abc123"
         data-clipboard-target="source" readonly
         class="w-full rounded-md border-gray-300 bg-gray-50" />
  <button data-action="clipboard#copy" class="btn btn-secondary">
    <span data-clipboard-target="button">Copy</span>
  </button>
</div>
```

Commonly used stimulus-components packages:

| Package | Behavior | Replaces |
|---------|----------|----------|
| `@stimulus-components/clipboard` | Copy to clipboard | Custom clipboard controller |
| `@stimulus-components/dropdown` | Toggle dropdown menus | Custom dropdown controller |
| `@stimulus-components/sortable` | Drag-and-drop reordering | Custom sortable with SortableJS |
| `@stimulus-components/tabs` | Tab switching | Custom tabs controller |
| `@stimulus-components/content-loader` | Lazy load content | Custom AJAX loader |
| `@stimulus-components/textarea-autogrow` | Auto-resize textareas | Custom resize observer |
| `@stimulus-components/notification` | Toast notifications | Custom notification controller |
| `@stimulus-components/character-counter` | Character count | Custom counter |

Also consider `stimulus-use` for composable behaviors you can mix into your own controllers:

```bash
yarn add stimulus-use
```

```javascript
// app/javascript/controllers/sidebar_controller.js
import { Controller } from "@hotwired/stimulus"
import { useClickOutside, useTransition } from "stimulus-use"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    useClickOutside(this)    // Adds clickOutside() callback
    useTransition(this)      // Adds enter()/leave() with CSS transitions
  }

  toggle() {
    this.toggleTransition()
  }

  clickOutside() {
    this.leave()
  }
}
```

Before writing any Stimulus controller, check:
1. [stimulus-components.com](https://www.stimulus-components.com/) -- 25+ ready-made controllers
2. [stimulus-use](https://stimulus-use.github.io/stimulus-use/) -- composable behaviors (click outside, idle, resize observer, etc.)
3. Search GitHub for `stimulus-{behavior}` -- the ecosystem is large

Reference: [stimulus-components](https://www.stimulus-components.com/)
