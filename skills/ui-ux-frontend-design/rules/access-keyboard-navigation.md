---
title: Ensure Full Keyboard Navigation
impact: CRITICAL
impactDescription: enables access for motor-impaired users and power users
tags: access, keyboard, focus, navigation, wcag
---

## Ensure Full Keyboard Navigation

All interactive elements must be reachable and operable via keyboard. Many users navigate entirely by keyboard due to motor disabilities, visual impairments, or preference.

**Incorrect (keyboard-inaccessible interactions):**

```html
<div class="dropdown" onmouseover="showMenu()">
  <span>Menu</span>
  <div class="menu-items">
    <div onclick="selectItem('option1')">Option 1</div>
    <div onclick="selectItem('option2')">Option 2</div>
  </div>
</div>
<!-- Cannot be reached with Tab key -->
<!-- Cannot be activated with Enter/Space -->
```

**Correct (keyboard-accessible implementation):**

```html
<div class="dropdown">
  <button
    aria-expanded="false"
    aria-haspopup="menu"
    onkeydown="handleKeydown(event)"
  >
    Menu
  </button>
  <ul role="menu">
    <li role="menuitem" tabindex="-1">Option 1</li>
    <li role="menuitem" tabindex="-1">Option 2</li>
  </ul>
</div>
<!-- Tab reaches button, Enter opens menu -->
<!-- Arrow keys navigate options, Escape closes -->
```

**Keyboard requirements:**
- Tab: Move between interactive elements
- Enter/Space: Activate buttons and links
- Arrow keys: Navigate within components (menus, tabs, sliders)
- Escape: Close modals and dropdowns

Reference: [WCAG 2.1 Keyboard Accessible](https://www.w3.org/WAI/WCAG21/Understanding/keyboard.html)
