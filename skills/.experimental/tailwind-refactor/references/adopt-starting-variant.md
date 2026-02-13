---
title: Use starting Variant for Entry Animations Without JS
impact: LOW-MEDIUM
impactDescription: eliminates JavaScript animation orchestration
tags: adopt, animation, transitions, starting-style
---

## Use starting Variant for Entry Animations Without JS

Entry animations for elements that appear on the page (popovers, dialogs, dynamically inserted content) traditionally require JavaScript to add/remove classes in a specific sequence. The `starting` variant maps to CSS `@starting-style`, which defines the initial state of an element before its first style update. Combined with the `open` variant for popovers and dialogs, you get smooth enter/exit animations purely in CSS.

**Incorrect (what's wrong):**

```html
<!-- JavaScript orchestration needed to animate entry -->
<div id="popover" popover class="opacity-100 transition-opacity duration-300">
<!-- JS: element.classList.add('opacity-0') then requestAnimationFrame to remove -->
```

**Correct (what's right):**

```html
<!-- CSS-only entry animation using starting variant -->
<div popover class="open:opacity-100 starting:open:opacity-0 transition-opacity duration-300">
</div>
```
