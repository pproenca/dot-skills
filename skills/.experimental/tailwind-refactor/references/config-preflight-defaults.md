---
title: Account for Preflight Default Changes in v4
impact: CRITICAL
impactDescription: prevents 3 visible UI regressions after migration
tags: config, preflight, defaults, v4-migration
---

## Account for Preflight Default Changes in v4

Tailwind v4 changed several Preflight (base reset) defaults that can cause visible regressions after migration. These are silent — no build errors, no warnings — but users will notice the differences immediately.

### Placeholder color

In v3, placeholder text used `gray-400`. In v4, placeholders use the current text color at 50% opacity.

**Incorrect (what's wrong):**

```html
<!-- Assumes v3 gray-400 placeholder color -->
<input class="text-gray-900" placeholder="Search..." />
```

**Correct (what's right):**

```html
<!-- Explicitly set placeholder color to match v3 appearance -->
<input class="text-gray-900 placeholder-gray-400" placeholder="Search..." />
```

### Button cursor

In v3, Preflight set `cursor: pointer` on all buttons. In v4, buttons use the browser default (`cursor: default`).

**Incorrect (what's wrong):**

```html
<!-- Assumes buttons have pointer cursor from Preflight -->
<button class="bg-blue-500 text-white px-4 py-2 rounded">Submit</button>
```

**Correct (what's right):**

```html
<!-- Explicitly add cursor-pointer to buttons -->
<button class="bg-blue-500 text-white px-4 py-2 rounded cursor-pointer">Submit</button>
```

Or apply globally in your CSS:

```css
@layer base {
  button, [role="button"] {
    cursor: pointer;
  }
}
```

### Dialog centering

In v3, Preflight centered `<dialog>` elements with `margin: auto`. In v4, dialogs use the browser default positioning.

**Incorrect (what's wrong):**

```html
<!-- Assumes dialog is auto-centered by Preflight -->
<dialog class="rounded-lg p-6 shadow-xl">
  <p>Modal content</p>
</dialog>
```

**Correct (what's right):**

```html
<!-- Explicitly center the dialog -->
<dialog class="mx-auto my-auto rounded-lg p-6 shadow-xl">
  <p>Modal content</p>
</dialog>
```
