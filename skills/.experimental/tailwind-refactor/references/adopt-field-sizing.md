---
title: Use field-sizing-content for Auto-Resizing Textareas
impact: LOW-MEDIUM
impactDescription: replaces JavaScript auto-resize with single CSS class
tags: adopt, forms, textarea, field-sizing
---

## Use field-sizing-content for Auto-Resizing Textareas

Auto-resizing textareas traditionally require JavaScript to measure `scrollHeight` and set inline styles on every input event. The `field-sizing-content` utility leverages a new CSS feature supported in Tailwind v4 that makes the element size itself to its content natively. No JavaScript, no layout thrashing, no edge cases with paste or undo.

**Incorrect (what's wrong):**

```html
<!-- JavaScript resize handler — extra code, layout thrashing on every keystroke -->
<textarea
  class="min-h-[80px] resize-none"
  oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px'"
></textarea>
```

**Correct (what's right):**

```html
<!-- Single utility class — textarea grows with content automatically -->
<textarea class="field-sizing-content min-h-20"></textarea>
```

The `field-sizing-content` utility also works on `<input>` elements, sizing them based on content width rather than a fixed `size` attribute.

**When NOT to use this pattern:**
- `field-sizing: content` is a bleeding-edge CSS property with limited browser support — as of early 2026, Firefox added support recently and Safari support may still be partial
- For production apps that must support older browsers, keep the JavaScript auto-resize as a fallback and use `field-sizing-content` as a progressive enhancement
- Check [caniuse.com](https://caniuse.com/mdn-css_properties_field-sizing_content) for current support before adopting
