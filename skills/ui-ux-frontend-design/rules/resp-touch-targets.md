---
title: Size Touch Targets for Mobile Interaction
impact: HIGH
impactDescription: reduces tap errors by 50%+, improves mobile usability
tags: resp, touch, mobile, buttons, accessibility
---

## Size Touch Targets for Mobile Interaction

Desktop hover states and small click targets don't work on touch devices. Mobile interfaces need larger tap targets and adequate spacing to prevent accidental taps.

**Incorrect (desktop-sized targets on mobile):**

```css
.nav-link {
  padding: 4px 8px;
  font-size: 12px;
}

.icon-button {
  width: 24px;
  height: 24px;
}

.action-buttons {
  display: flex;
  gap: 4px;
}
/* 24px targets are nearly impossible to tap accurately */
/* 4px gap means constant accidental taps on wrong button */
```

**Correct (mobile-optimized touch targets):**

```css
.nav-link {
  padding: 12px 16px;
  font-size: 16px;
  min-height: 44px;
  display: inline-flex;
  align-items: center;
}

.icon-button {
  min-width: 44px;
  min-height: 44px;
  padding: 10px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.action-buttons {
  display: flex;
  gap: 12px; /* Enough space to prevent mis-taps */
}
/* 44×44px minimum touch target */
/* 12px gap provides safe spacing between actions */
```

**Touch target guidelines:**
- Minimum 44×44px (Apple HIG) or 48×48px (Material Design)
- Minimum 8px spacing between adjacent targets
- Padding counts toward target size, not just visible element
- Inline text links exempt, but consider touch on mobile

Reference: [Apple HIG Touch Targets](https://developer.apple.com/design/human-interface-guidelines/accessibility#Buttons-and-controls)
