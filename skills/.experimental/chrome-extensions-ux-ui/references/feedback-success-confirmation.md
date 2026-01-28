---
title: Confirm Successful Actions
impact: MEDIUM
impactDescription: builds user confidence and trust
tags: feedback, success, confirmation, toast, user-confidence
---

## Confirm Successful Actions

Provide clear confirmation when actions complete successfully. Silent success leaves users uncertain whether their action worked.

**Incorrect (silent success):**

```typescript
// popup.js - No feedback on success
async function saveNote() {
  await chrome.storage.local.set({ note: noteContent })
  // Nothing happens - user wonders if it saved
}

async function copyToClipboard(text) {
  await navigator.clipboard.writeText(text)
  // Did it copy? User has no idea
}
```

**Correct (explicit success feedback):**

```typescript
// popup.js - Clear success confirmation
async function saveNote() {
  const saveBtn = document.getElementById('save-btn')

  try {
    await chrome.storage.local.set({ note: noteContent })

    // Visual confirmation
    saveBtn.classList.add('success')
    saveBtn.textContent = 'Saved!'

    // Show toast notification
    showToast('Note saved successfully', 'success')

    // Reset after delay
    setTimeout(() => {
      saveBtn.classList.remove('success')
      saveBtn.textContent = 'Save'
    }, 2000)
  } catch (error) {
    showToast('Failed to save', 'error')
  }
}

async function copyToClipboard(text) {
  try {
    await navigator.clipboard.writeText(text)
    showToast('Copied to clipboard!', 'success')
  } catch (error) {
    showToast('Copy failed', 'error')
  }
}

function showToast(message, type = 'info') {
  const toast = document.createElement('div')
  toast.className = `toast toast-${type}`
  toast.setAttribute('role', 'status')
  toast.setAttribute('aria-live', 'polite')
  toast.innerHTML = `
    <span class="toast-icon">${type === 'success' ? '✓' : '!'}</span>
    <span class="toast-message">${message}</span>
  `

  document.getElementById('toast-container').appendChild(toast)

  // Auto-dismiss
  setTimeout(() => {
    toast.classList.add('fade-out')
    setTimeout(() => toast.remove(), 300)
  }, 3000)
}
```

**Contextual success patterns:**

```typescript
// Different confirmation styles for different actions
const confirmationPatterns = {
  // Inline confirmation - for quick actions
  async quickSave() {
    await save()
    const indicator = document.getElementById('save-indicator')
    indicator.textContent = '✓ Saved'
    indicator.classList.add('visible')
    setTimeout(() => indicator.classList.remove('visible'), 1500)
  },

  // Button state change - for form submissions
  async submitForm(button) {
    button.disabled = true
    button.textContent = 'Submitting...'
    await submit()
    button.textContent = '✓ Submitted'
    button.classList.add('success')
  },

  // Toast - for background operations
  async backgroundSync() {
    await sync()
    showToast('All changes synced', 'success')
  },

  // Badge flash - for extension-wide actions
  async extensionAction() {
    await performAction()
    await chrome.action.setBadgeText({ text: '✓' })
    await chrome.action.setBadgeBackgroundColor({ color: '#28a745' })
    setTimeout(async () => {
      await chrome.action.setBadgeText({ text: '' })
    }, 2000)
  }
}
```

**Success feedback guidelines:**
- Match feedback prominence to action importance
- Auto-dismiss after 2-3 seconds
- Use checkmarks (✓) universally understood as success
- Make feedback accessible (role="status", aria-live)

Reference: [Toast Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/alert/)
