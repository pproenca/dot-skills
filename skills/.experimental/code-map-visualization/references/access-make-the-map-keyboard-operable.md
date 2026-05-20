---
title: Make Every Map Action Keyboard-Operable
impact: MEDIUM
impactDescription: prevents locking out non-pointer users
tags: access, keyboard, focus, wcag, operability
---

## Make Every Map Action Keyboard-Operable

WCAG 2.1.1 requires every action to be reachable by keyboard, and a canvas is a black box to assistive technology by default — focus order, visible focus, and freedom from keyboard traps must be added deliberately. Beyond wiring keys to the camera ([[interact-support-keyboard-pan-zoom-and-focus]]), make the canvas focusable, show a visible focus ring on the selected cell, expose the actions as real controls or documented shortcuts, and ensure focus can always leave the map. This is what makes the keyboard path usable, not merely present.

**Incorrect (canvas cannot receive focus; selection has no visible state):**

```typescript
<canvas id="map" />   // keyboard users cannot reach it or see what is selected
```

**Correct (focusable, announces its role, draws a focus ring, never traps):**

```typescript
<canvas
  id="map"
  tabIndex={0}
  role="application"
  aria-label="Code map — arrow keys pan, plus/minus zoom, Enter selects"
  onKeyDown={onMapKey}   // Escape moves focus out; a ring is drawn for focusedCell
/>
```

**When NOT to apply:**
- A static, non-interactive image of the map exposes no actions, so it needs alt text ([[access-provide-a-text-alternative-for-the-canvas]]) rather than keyboard handlers.

Reference: [WCAG 2.2 — Keyboard (2.1.1)](https://www.w3.org/WAI/WCAG22/Understanding/keyboard.html); [MDN — ARIA application role](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/application_role)
