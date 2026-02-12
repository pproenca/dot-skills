---
title: Keep Controllers Under 50 Lines
impact: MEDIUM
impactDescription: prevents JavaScript soup in controller files
tags: stim, stimulus, architecture, code-size
---

## Keep Controllers Under 50 Lines

Fat Stimulus controllers are the same anti-pattern as fat Rails controllers. When a controller handles form validation, submission, UI feedback, and analytics tracking, it becomes hard to test, hard to reuse, and hard to debug. If a controller exceeds 50 lines, split it into smaller, composable controllers or extract utility functions.

**Incorrect (150-line monolithic controller):**

```javascript
// app/javascript/controllers/mega_form_controller.js — 150+ lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "email", "password", "strength", "submit",
                     "charCount", "maxChars", "toast", "spinner"]

  connect() {
    this.maxLength = 500
    this.updateCharCount()
    this.validateAll()
  }

  validateEmail() { /* 15 lines of email validation */ }
  validatePassword() { /* 20 lines of password strength checking */ }
  validateAll() { /* combines all validations */ }
  updateStrengthMeter() { /* password strength UI */ }
  updateCharCount() { /* character counting logic */ }
  submit(event) { /* form submission with fetch */ }
  showSpinner() { /* loading state UI */ }
  hideSpinner() { /* loading state UI */ }
  showToast(message) { /* toast notification logic */ }
  hideToast() { /* auto-dismiss logic */ }
  trackFormStart() { /* analytics */ }
  trackFormSubmit() { /* analytics */ }
  trackFormError() { /* analytics */ }
}
```

**Correct (small, focused controllers composed together):**

```javascript
// app/javascript/controllers/form_validation_controller.js — ~25 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "submit"]

  validate() {
    const allValid = this.fieldTargets.every(field => field.checkValidity())
    this.submitTarget.disabled = !allValid
  }
}
```

```javascript
// app/javascript/controllers/char_count_controller.js — ~20 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: { type: Number, default: 500 } }

  update() {
    const remaining = this.maxValue - this.inputTarget.value.length
    this.countTarget.textContent = `${remaining} characters remaining`
    this.countTarget.classList.toggle("text-red-600", remaining < 20)
  }

  connect() { this.update() }
}
```

```javascript
// app/javascript/controllers/form_submit_controller.js — ~30 lines
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit"]

  async submit(event) {
    event.preventDefault()
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "Saving..."

    try {
      const response = await fetch(this.formTarget.action, {
        method: this.formTarget.method,
        body: new FormData(this.formTarget),
        headers: { "Accept": "text/vnd.turbo-stream.html" }
      })
      if (!response.ok) throw new Error("Submit failed")
    } catch (error) {
      this.submitTarget.disabled = false
      this.submitTarget.textContent = "Save"
    }
  }
}
```

```erb
<%# Compose multiple small controllers on one form %>
<%= form_with model: @post,
  data: {
    controller: "form-validation char-count form-submit",
    action: "submit->form-submit#submit"
  } do |f| %>

  <%= f.text_area :body,
    data: {
      form_validation_target: "field",
      char_count_target: "input",
      action: "input->form-validation#validate input->char-count#update"
    } %>

  <p data-char-count-target="count" class="text-sm text-gray-500"></p>

  <%= f.submit "Publish",
    data: {
      form_validation_target: "submit",
      form_submit_target: "submit"
    } %>
<% end %>
```

Rule of thumb: if you need to scroll to read a controller, it is too long.

Reference: [Stimulus Handbook - Managing State](https://stimulus.hotwired.dev/handbook/managing-state)
