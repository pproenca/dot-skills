---
title: Remove Display Overrides for hidden Attribute
impact: HIGH
impactDescription: removes 50% of show/hide JavaScript logic
tags: class, hidden, display, priority
---

## Remove Display Overrides for hidden Attribute

In Tailwind CSS v3, display utilities like `block` or `flex` overrode the HTML `hidden` attribute, meaning `<div hidden class="block">` would still be visible. This forced developers to write extra JavaScript to toggle both the `hidden` attribute and the display class simultaneously. In v4, the `hidden` attribute takes priority over display classes, so `<div hidden class="flex">` correctly stays hidden. You can simplify show/hide logic by relying solely on the `hidden` attribute.

**Incorrect (what's wrong):**

```html
<!-- v3 pattern: JS must toggle both hidden and display class -->
<div id="panel" hidden class="hidden">
  Panel content
</div>
<script>
  function showPanel() {
    panel.removeAttribute('hidden');
    panel.classList.remove('hidden');
    panel.classList.add('flex');
  }
</script>
```

**Correct (what's right):**

```html
<!-- v4 pattern: hidden attribute alone controls visibility -->
<div id="panel" hidden class="flex">
  Panel content
</div>
<script>
  function showPanel() {
    panel.removeAttribute('hidden');
  }
</script>
```
