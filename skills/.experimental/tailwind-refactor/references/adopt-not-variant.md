---
title: Use not-* Variant for Negated Conditions
impact: LOW-MEDIUM
impactDescription: replaces workaround patterns with single variant
tags: adopt, variants, pseudo-classes, conditional
---

## Use not-* Variant for Negated Conditions

Tailwind v4 introduces the `not-*` variant to express negated conditions directly — "apply this style when the condition is NOT met." This is most valuable for pseudo-classes like `:disabled`, `:focus`, and `:empty` where the base-override pattern is awkward or verbose. For simple hover interactions, the standard `base hover:override` pattern remains idiomatic and often clearer.

**Incorrect (what's wrong):**

```html
<!-- Workaround: must override multiple properties to style "not disabled" -->
<button class="opacity-50 cursor-not-allowed disabled:opacity-50 disabled:cursor-not-allowed enabled:opacity-100 enabled:cursor-pointer">
  Submit
</button>
```

**Correct (what's right):**

```html
<!-- Direct negation: style only when NOT disabled -->
<button class="not-disabled:opacity-100 not-disabled:cursor-pointer opacity-50 cursor-not-allowed">
  Submit
</button>
```

The `not-*` variant works with pseudo-classes, media queries, and supports queries:

```html
<input class="not-focus:ring-0" />
<div class="not-supports-[backdrop-filter]:bg-gray-900">Fallback</div>
<div class="not-empty:p-4">Only pad when has content</div>
```

**When NOT to use this pattern:**
- The standard `base hover:override` pattern (e.g., `opacity-75 hover:opacity-100`) remains valid and preferred for simple hover interactions — do not rewrite it with `not-hover:`
- Avoid `not-*` when the base-override approach is already clear and well-understood
