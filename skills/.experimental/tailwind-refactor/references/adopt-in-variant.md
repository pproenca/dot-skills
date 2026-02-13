---
title: Use in-* Variant to Simplify Parent-State Styling
impact: LOW-MEDIUM
impactDescription: eliminates need for explicit group markers
tags: adopt, variants, group, parent-state
---

## Use in-* Variant to Simplify Parent-State Styling

The `group` / `group-*` pattern requires adding an explicit `group` class to a parent element so children can react to its state. The `in-*` variant removes this requirement — it targets the nearest ancestor matching the condition implicitly. This means cleaner markup and one fewer class to maintain.

**Incorrect (verbose — group is valid but more markup):**

```html
<!-- Must remember to add "group" class to parent -->
<div class="group rounded-lg p-4 hover:bg-gray-100">
  <p class="group-hover:text-blue-500">Title</p>
  <p class="group-hover:text-gray-600">Description</p>
</div>
```

**Correct (concise — in-* removes group boilerplate):**

```html
<!-- No group class needed — in-* targets nearest matching ancestor -->
<div class="rounded-lg p-4 hover:bg-gray-100">
  <p class="in-hover:text-blue-500">Title</p>
  <p class="in-hover:text-gray-600">Description</p>
</div>
```

**When NOT to use this pattern:**
- `group` is still fully supported and idiomatic in v4 — `in-*` is a convenience, not a deprecation
- Use `group/name` (named groups) when you need to target a specific ancestor in deeply nested structures — `in-*` always targets the nearest matching ancestor which may not be the intended one
- Keep `group` when multiple nested components could match and you need explicit opt-in control over which ancestor is the target
