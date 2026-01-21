---
title: Use Appropriate Animation Duration and Easing
impact: LOW-MEDIUM
impactDescription: 100-400ms optimal ranges reduce perceived latency
tags: anim, duration, easing, timing, css
---

## Use Appropriate Animation Duration and Easing

Too-slow animations feel laggy; too-fast ones feel jarring. Proper duration and easing curves make interfaces feel responsive and natural.

**Incorrect (wrong durations and linear easing):**

```css
/* Too slow for microinteraction */
.button:hover {
  transition: background-color 1s linear;
}
/* Feels sluggish, user waits for response */

/* Too fast for modal */
.modal {
  transition: opacity 50ms linear;
}
/* Feels abrupt, jarring */

/* Linear easing on movement */
.dropdown {
  transition: transform 0.3s linear;
}
/* Feels mechanical, robotic */
```

**Correct (appropriate durations with natural easing):**

```css
/* Microinteractions: 100-200ms */
.button {
  transition: background-color 150ms ease-out;
}

.checkbox {
  transition: transform 100ms ease-out;
}

/* Expand/collapse: 200-300ms */
.dropdown {
  transition: transform 250ms cubic-bezier(0.4, 0, 0.2, 1);
}

/* Modal/overlay: 200-400ms */
.modal {
  transition: opacity 200ms ease-out,
              transform 300ms cubic-bezier(0.32, 0.72, 0, 1);
}

/* Page transitions: 300-500ms */
.page-transition {
  transition: transform 400ms cubic-bezier(0.4, 0, 0.2, 1);
}
```

**Duration guidelines by action type:**
| Action | Duration |
|--------|----------|
| Hover/focus states | 100-150ms |
| Button feedback | 100-200ms |
| Dropdowns/accordions | 200-300ms |
| Modals/dialogs | 200-400ms |
| Page transitions | 300-500ms |

**Common easing curves:**
- `ease-out`: Fast start, slow end (entering)
- `ease-in`: Slow start, fast end (exiting)
- `cubic-bezier(0.4, 0, 0.2, 1)`: Material Design standard

Reference: [Material Design Motion](https://m3.material.io/styles/motion/easing-and-duration/tokens-specs)
