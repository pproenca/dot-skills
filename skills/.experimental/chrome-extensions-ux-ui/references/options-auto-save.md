---
title: Auto-Save Settings on Change
impact: MEDIUM
impactDescription: eliminates lost settings and save button friction
tags: options, auto-save, persistence, ux, real-time
---

## Auto-Save Settings on Change

Save settings immediately when users change them. Requiring manual save leads to lost changes and adds unnecessary friction.

**Incorrect (requires manual save):**

```html
<!-- options.html - User must remember to save -->
<form id="settings-form">
  <label>
    <input type="checkbox" name="darkMode">
    Dark mode
  </label>

  <label>
    <input type="checkbox" name="notifications">
    Enable notifications
  </label>

  <button type="submit">Save Settings</button>
</form>
```

```typescript
// options.js - Manual save required
document.getElementById('settings-form').addEventListener('submit', async (e) => {
  e.preventDefault()
  const formData = new FormData(e.target)
  await chrome.storage.sync.set({
    darkMode: formData.has('darkMode'),
    notifications: formData.has('notifications')
  })
  showMessage('Settings saved!')
})
// User changes settings → closes tab → LOST because they forgot to save
```

**Correct (auto-save on every change):**

```html
<!-- options.html - Changes save automatically -->
<form id="settings-form">
  <label>
    <input type="checkbox" name="darkMode">
    Dark mode
  </label>

  <label>
    <input type="checkbox" name="notifications">
    Enable notifications
  </label>

  <div class="save-status" id="save-status"></div>
</form>
```

```typescript
// options.js - Auto-save with feedback
const form = document.getElementById('settings-form')
const statusEl = document.getElementById('save-status')
let saveTimeout = null

// Load saved settings on open
chrome.storage.sync.get(['darkMode', 'notifications'], (settings) => {
  form.elements.darkMode.checked = settings.darkMode ?? false
  form.elements.notifications.checked = settings.notifications ?? true
})

// Save on any change
form.addEventListener('change', (event) => {
  const input = event.target
  const value = input.type === 'checkbox' ? input.checked : input.value

  // Show saving status
  statusEl.textContent = 'Saving...'
  statusEl.className = 'save-status saving'

  // Debounce for text inputs
  clearTimeout(saveTimeout)
  saveTimeout = setTimeout(async () => {
    try {
      await chrome.storage.sync.set({ [input.name]: value })
      statusEl.textContent = 'Saved'
      statusEl.className = 'save-status saved'

      // Clear status after delay
      setTimeout(() => {
        statusEl.textContent = ''
      }, 2000)
    } catch (error) {
      statusEl.textContent = 'Save failed'
      statusEl.className = 'save-status error'
    }
  }, input.type === 'text' ? 500 : 0) // Immediate for checkboxes, debounced for text
})
```

**Auto-save with validation:**

```typescript
// options.js - Validate before saving
async function handleSettingChange(input) {
  const value = input.value
  const name = input.name

  // Validate
  const validationResult = validateSetting(name, value)
  if (!validationResult.valid) {
    showFieldError(input, validationResult.message)
    return // Don't save invalid values
  }

  clearFieldError(input)
  await saveSetting(name, value)
  showSaveConfirmation()
}

function validateSetting(name, value) {
  const validators = {
    apiKey: (v) => v.length >= 32 ? { valid: true } : { valid: false, message: 'API key must be at least 32 characters' },
    refreshInterval: (v) => v >= 1 && v <= 60 ? { valid: true } : { valid: false, message: 'Must be 1-60 minutes' }
  }

  return validators[name]?.(value) ?? { valid: true }
}
```

Reference: [Options Page Best Practices](https://developer.chrome.com/docs/extensions/develop/ui/options-page)
