---
title: Use data-turbo-confirm for Destructive Actions
impact: MEDIUM-HIGH
impactDescription: prevents accidental data loss with zero-JavaScript confirmation
tags: drive, confirm, dialog, destructive-actions
---

## Use data-turbo-confirm for Destructive Actions

Turbo intercepts all form submissions and link clicks, which means the traditional `data: { confirm: "Are you sure?" }` Rails helper still works but uses the browser's native `window.confirm()` dialog. For custom-styled confirmation modals, override `Turbo.setConfirmMethod` with a function that returns a Promise. This keeps destructive action protection declarative in HTML while supporting branded modal designs.

**Incorrect (inline JavaScript onclick handler for confirmation):**

```erb
<%# app/views/projects/_project.html.erb %>
<%= button_to "Delete", project_path(project), method: :delete,
    onclick: "return confirm('Are you sure?')" %>

<%# Or worse: Stimulus controller doing the fetch manually %>
<button data-controller="delete"
        data-action="click->delete#confirm"
        data-delete-url-value="<%= project_path(project) %>">
  Delete
</button>
```

```js
// BAD: manually handling the confirmation flow and submission
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  confirm() {
    if (window.confirm("Are you sure?")) {
      fetch(this.urlValue, { method: "DELETE", headers: { "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content } })
        .then(() => window.location.reload())
    }
  }
}
```

**Correct (data-turbo-confirm with native or custom modal):**

```erb
<%# Native browser confirm — works out of the box %>
<%= button_to "Delete", project_path(project), method: :delete,
    form: { data: { turbo_confirm: "Delete this project? This cannot be undone." } } %>

<%# Works on links too %>
<%= link_to "Remove member", project_member_path(project, member),
    data: { turbo_method: :delete, turbo_confirm: "Remove this team member?" } %>
```

```js
// For custom-styled modals, override Turbo.setConfirmMethod once in application.js
import "@hotwired/turbo-rails"

Turbo.setConfirmMethod((message, element) => {
  // Return a Promise that resolves to true (proceed) or false (cancel)
  return new Promise((resolve) => {
    const dialog = document.getElementById("confirm-dialog")
    dialog.querySelector("[data-message]").textContent = message
    dialog.querySelector("[data-confirm]").onclick = () => {
      dialog.close()
      resolve(true)
    }
    dialog.querySelector("[data-cancel]").onclick = () => {
      dialog.close()
      resolve(false)
    }
    dialog.showModal()
  })
})
```

```erb
<%# app/views/layouts/application.html.erb %>
<dialog id="confirm-dialog" class="modal">
  <p data-message></p>
  <div class="modal-actions">
    <button data-cancel class="btn btn-secondary">Cancel</button>
    <button data-confirm class="btn btn-danger">Confirm</button>
  </div>
</dialog>
```

Reference: [Turbo Handbook — Confirmation](https://turbo.hotwired.dev/handbook/drive#requiring-confirmation-for-a-visit)
