---
title: Compose Multiple Controllers on One Element
impact: MEDIUM
impactDescription: reduces controller size by 50-70% through composition
tags: stim, stimulus, composition, architecture
---

## Compose Multiple Controllers on One Element

Stimulus's core architectural feature is that multiple controllers can coexist on a single DOM element. Instead of building a monolithic controller that handles everything, compose small, focused controllers that each handle one responsibility. This is Stimulus's equivalent of the single-responsibility principle.

**Incorrect (one monolithic controller doing everything):**

```javascript
// app/javascript/controllers/mega_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Handles: validation, autosave, character count, password strength,
  // dirty tracking, and keyboard shortcuts — all in one file

  static targets = ["input", "count", "strengthMeter", "saveIndicator", "form"]

  validate() { /* ... */ }
  autosave() { /* ... */ }
  updateCharCount() { /* ... */ }
  checkPasswordStrength() { /* ... */ }
  trackDirtyState() { /* ... */ }
  handleKeyboard(event) { /* ... */ }
}
```

```erb
<form data-controller="mega-form">
  <%# All behavior locked into one controller %>
</form>
```

**Correct (multiple small controllers composed on the same element):**

```javascript
// app/javascript/controllers/autosave_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    delay: { type: Number, default: 1000 }
  }
  static targets = ["indicator"]

  save() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.persist(), this.delayValue)
  }

  async persist() {
    this.indicatorTarget.textContent = "Saving..."
    await fetch(this.urlValue, {
      method: "PATCH",
      body: new FormData(this.element),
      headers: { "X-CSRF-Token": document.querySelector("[name='csrf-token']").content }
    })
    this.indicatorTarget.textContent = "Saved"
  }
}
```

```javascript
// app/javascript/controllers/dirty_tracker_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  connect() {
    this.initialValues = this.fieldTargets.map(f => f.value)
  }

  check() {
    const isDirty = this.fieldTargets.some((f, i) => f.value !== this.initialValues[i])
    this.element.dataset.dirty = isDirty

    window.onbeforeunload = isDirty ? () => "Unsaved changes" : null
  }

  reset() {
    this.initialValues = this.fieldTargets.map(f => f.value)
    this.check()
  }
}
```

```javascript
// app/javascript/controllers/keyboard_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
```

```erb
<%# Three independent controllers on one form — each handles one concern %>
<%= form_with model: @post, data: {
  controller: "autosave dirty-tracker keyboard-submit",
  autosave_url_value: autosave_post_path(@post),
  autosave_delay_value: 2000,
  action: "keydown->keyboard-submit#submit"
} do |f| %>

  <%= f.text_field :title, data: {
    dirty_tracker_target: "field",
    action: "input->autosave#save input->dirty-tracker#check"
  } %>

  <%= f.text_area :body, data: {
    dirty_tracker_target: "field",
    action: "input->autosave#save input->dirty-tracker#check"
  } %>

  <span data-autosave-target="indicator" class="text-sm text-gray-500"></span>

  <%= f.submit "Publish" %>
<% end %>
```

Each controller can be:
- Tested independently
- Reused on different forms
- Removed without affecting the others
- Understood in isolation

Reference: [Stimulus Handbook - Installing Stimulus](https://stimulus.hotwired.dev/handbook/installing)
