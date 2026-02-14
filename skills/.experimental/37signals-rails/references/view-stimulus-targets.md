---
title: Stimulus Targets Over CSS Selectors
impact: MEDIUM
impactDescription: 0 broken bindings during CSS refactoring
tags: view, stimulus, targets, javascript
---

## Stimulus Targets Over CSS Selectors

Use Stimulus `data-*-target` attributes instead of `querySelector` or CSS class selectors to bind JavaScript behavior to DOM elements. Targets are declared explicitly in the controller's `static targets` array, making them discoverable and documented. When designers rename CSS classes or restructure markup, behavior bindings remain intact because targets are independent of styling.

**Incorrect (querySelector with CSS selectors for DOM access):**

```ruby
# app/views/cards/show.html.erb
<div class="card-detail">
  <textarea class="card-description js-editable-field"></textarea>
  <span class="char-count js-char-counter">0/500</span>
  <button class="btn btn-primary js-save-btn" disabled>Save</button>
</div>

<script>
  // Brittle: renaming CSS classes or restructuring HTML breaks behavior
  const field = document.querySelector(".js-editable-field");
  const counter = document.querySelector(".js-char-counter");
  const saveBtn = document.querySelector(".js-save-btn");

  field.addEventListener("input", () => {
    const count = field.value.length;
    counter.textContent = `${count}/500`;
    saveBtn.disabled = count === 0 || count > 500;

    if (count > 500) {
      counter.classList.add("text-danger");
    } else {
      counter.classList.remove("text-danger");
    }
  });
</script>
```

**Correct (Stimulus controller with declared targets):**

```ruby
# app/views/cards/show.html.erb
<div data-controller="character-counter" data-character-counter-max-value="500">
  <textarea
    data-character-counter-target="input"
    data-action="input->character-counter#count"
  ></textarea>
  <span data-character-counter-target="counter">0/500</span>
  <button data-character-counter-target="submit" disabled>Save</button>
</div>

# app/javascript/controllers/character_counter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "submit"]
  static values = { max: { type: Number, default: 500 } }

  count() {
    const length = this.inputTarget.value.length
    this.counterTarget.textContent = `${length}/${this.maxValue}`
    this.submitTarget.disabled = length === 0 || length > this.maxValue
    this.counterTarget.classList.toggle("text-danger", length > this.maxValue)
  }
}
```

**Benefits:**
- `static targets` serves as documentation — scanning the controller reveals all required DOM elements
- CSS class renames (`btn-primary` to `button--primary`) cannot break behavior
- Stimulus auto-connects when elements appear in the DOM (works with Turbo Frame updates)
- Multiple instances of the same controller work independently on the same page

**When NOT to use:** For one-off behavior that is truly tied to a specific CSS state (e.g., reading computed styles, animation callbacks), direct DOM access within a Stimulus controller method is acceptable. The point is to avoid using CSS selectors as the primary mechanism for locating elements.

Reference: [Basecamp Fizzy](https://github.com/basecamp/fizzy)
