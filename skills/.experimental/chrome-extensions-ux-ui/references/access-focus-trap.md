---
title: Avoid Keyboard Focus Traps
impact: CRITICAL
impactDescription: WCAG 2.1.2 - users must be able to exit any UI
tags: access, focus, trap, keyboard, modal
---

## Avoid Keyboard Focus Traps

Ensure keyboard users can always navigate out of any component. A focus trap occurs when Tab/Shift+Tab cycling never escapes an element, leaving users stuck.

**Incorrect (modal traps focus permanently):**

```typescript
// modal.js - No way to close with keyboard
function openModal() {
  const modal = document.getElementById('modal')
  modal.style.display = 'block'
  modal.querySelector('input').focus()

  // Focus trapped - no Escape handler, no close button focus
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      const focusable = modal.querySelectorAll('input, button')
      const first = focusable[0]
      const last = focusable[focusable.length - 1]

      if (e.shiftKey && document.activeElement === first) {
        last.focus()
        e.preventDefault()
      } else if (!e.shiftKey && document.activeElement === last) {
        first.focus()
        e.preventDefault()
      }
    }
  })
  // Keyboard user cannot escape modal
}
```

**Correct (focus contained but escapable):**

```typescript
// modal.js - Escape key and close button allow exit
function openModal() {
  const modal = document.getElementById('modal')
  const closeButton = modal.querySelector('.close-btn')
  const focusableElements = modal.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  )
  const firstFocusable = focusableElements[0]
  const lastFocusable = focusableElements[focusableElements.length - 1]

  modal.style.display = 'block'
  firstFocusable.focus()

  function handleKeydown(event) {
    if (event.key === 'Escape') {
      closeModal()
      return
    }

    if (event.key === 'Tab') {
      if (event.shiftKey && document.activeElement === firstFocusable) {
        lastFocusable.focus()
        event.preventDefault()
      } else if (!event.shiftKey && document.activeElement === lastFocusable) {
        firstFocusable.focus()
        event.preventDefault()
      }
    }
  }

  function closeModal() {
    modal.style.display = 'none'
    document.removeEventListener('keydown', handleKeydown)
    previouslyFocusedElement.focus()  // Return focus to trigger
  }

  document.addEventListener('keydown', handleKeydown)
  closeButton.addEventListener('click', closeModal)
}
```

**Focus trap requirements:**
- Escape key must close dialogs/modals
- Close button must be keyboard accessible
- Focus returns to the element that opened the dialog

Reference: [WCAG 2.1.2 No Keyboard Trap](https://www.w3.org/WAI/WCAG21/Understanding/no-keyboard-trap.html)
