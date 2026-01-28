---
title: Handle Popup Auto-Close Gracefully
impact: HIGH
impactDescription: prevents data loss and user frustration
tags: popup, auto-close, state, persistence, user-data
---

## Handle Popup Auto-Close Gracefully

Save user input continuously because popups close instantly when users click outside. Never require explicit save actions for in-progress work.

**Incorrect (data lost on auto-close):**

```typescript
// popup.js - User input lost when popup closes
const textarea = document.getElementById('notes')
const saveButton = document.getElementById('save')

saveButton.addEventListener('click', () => {
  chrome.storage.local.set({ notes: textarea.value })
})
// User types notes → clicks page to copy something → popup closes → notes LOST
```

**Correct (continuous auto-save):**

```typescript
// popup.js - Save on every change
const textarea = document.getElementById('notes')
let saveTimeout = null

// Load existing content on open
chrome.storage.local.get('notes', (result) => {
  textarea.value = result.notes || ''
})

// Debounced auto-save on every keystroke
textarea.addEventListener('input', () => {
  // Show saving indicator
  showSavingIndicator()

  // Debounce to avoid excessive writes
  clearTimeout(saveTimeout)
  saveTimeout = setTimeout(() => {
    chrome.storage.local.set({ notes: textarea.value }, () => {
      showSavedIndicator()
    })
  }, 300)
})

// Also save immediately before popup closes
window.addEventListener('beforeunload', () => {
  chrome.storage.local.set({ notes: textarea.value })
})
```

**For forms with multiple fields:**

```typescript
// popup.js - Auto-save entire form state
const form = document.getElementById('settings-form')

// Restore state on open
chrome.storage.local.get('formDraft', (result) => {
  if (result.formDraft) {
    Object.entries(result.formDraft).forEach(([name, value]) => {
      const field = form.elements[name]
      if (field) field.value = value
    })
  }
})

// Save state on any change
form.addEventListener('input', () => {
  const formData = new FormData(form)
  const draft = Object.fromEntries(formData.entries())
  chrome.storage.local.set({ formDraft: draft })
})

// Clear draft only after successful submission
form.addEventListener('submit', async (event) => {
  event.preventDefault()
  await submitForm()
  await chrome.storage.local.remove('formDraft')
})
```

**When NOT to auto-save:**
- Destructive actions (delete, send)—always require explicit confirmation
- Sensitive data that shouldn't persist

Reference: [Storage API](https://developer.chrome.com/docs/extensions/reference/api/storage)
