---
title: Use in-* Variant Instead of group Class
impact: LOW-MEDIUM
impactDescription: eliminates need for explicit group markers
tags: adopt, variants, group, parent-state
---

## Use in-* Variant Instead of group Class

The `group` / `group-*` pattern requires adding an explicit `group` class to a parent element so children can react to its state. The `in-*` variant removes this requirement — it targets the nearest ancestor matching the condition implicitly. This means cleaner markup and one fewer class to maintain.

**Incorrect (what's wrong):**

```html
<!-- Must remember to add "group" class to parent -->
<div class="group rounded-lg p-4 hover:bg-gray-100">
  <p class="group-hover:text-blue-500">Title</p>
  <p class="group-hover:text-gray-600">Description</p>
</div>
```

**Correct (what's right):**

```html
<!-- No group class needed — in-* targets nearest matching ancestor -->
<div class="rounded-lg p-4 hover:bg-gray-100">
  <p class="in-hover:text-blue-500">Title</p>
  <p class="in-hover:text-gray-600">Description</p>
</div>
```
