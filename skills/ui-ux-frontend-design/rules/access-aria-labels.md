---
title: Use ARIA Labels for Icon-Only Controls
impact: CRITICAL
impactDescription: enables screen readers to announce button purpose
tags: access, aria, labels, icons, screen-readers
---

## Use ARIA Labels for Icon-Only Controls

Buttons and links with only icons have no accessible name. Screen readers announce "button" with no context, leaving users unable to understand the control's purpose.

**Incorrect (icon buttons without accessible names):**

```html
<button class="icon-btn">
  <svg><!-- hamburger menu icon --></svg>
</button>
<!-- Screen reader: "button" -->

<button>
  <i class="fa fa-trash"></i>
</button>
<!-- Screen reader: "button" -->

<a href="/cart">
  <svg><!-- cart icon --></svg>
</a>
<!-- Screen reader: "link" -->
```

**Correct (icon buttons with accessible names):**

```html
<button class="icon-btn" aria-label="Open navigation menu">
  <svg aria-hidden="true"><!-- hamburger menu icon --></svg>
</button>
<!-- Screen reader: "Open navigation menu, button" -->

<button aria-label="Delete item">
  <i class="fa fa-trash" aria-hidden="true"></i>
</button>
<!-- Screen reader: "Delete item, button" -->

<a href="/cart" aria-label="Shopping cart, 3 items">
  <svg aria-hidden="true"><!-- cart icon --></svg>
  <span class="badge">3</span>
</a>
<!-- Screen reader: "Shopping cart, 3 items, link" -->
```

**ARIA labeling rules:**
- Use `aria-label` for concise names
- Use `aria-labelledby` to reference visible text elsewhere
- Add `aria-hidden="true"` to decorative icons
- Update dynamic labels (cart count, notification badges)

Reference: [ARIA Labels and Relationships](https://www.w3.org/WAI/tutorials/forms/labels/)
