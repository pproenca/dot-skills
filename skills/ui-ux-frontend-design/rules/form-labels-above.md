---
title: Place Labels Above Input Fields
impact: MEDIUM
impactDescription: improves form completion speed by 15%
tags: form, labels, layout, ux, accessibility
---

## Place Labels Above Input Fields

Labels placed above inputs create a clear visual path and work better on mobile. Left-aligned labels require horizontal eye movement and break at narrow widths.

**Incorrect (labels beside inputs):**

```html
<div class="form-row">
  <label>Email Address</label>
  <input type="email">
</div>

<style>
.form-row {
  display: flex;
  align-items: center;
}
.form-row label {
  width: 150px;
  text-align: right;
  padding-right: 12px;
}
</style>
<!-- Eye must zigzag horizontally -->
<!-- Breaks on mobile (labels get cut off or wrap awkwardly) -->
```

**Correct (labels above inputs):**

```html
<div class="form-field">
  <label for="email">Email Address</label>
  <input type="email" id="email" name="email">
</div>

<style>
.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 24px;
}

.form-field label {
  font-weight: 500;
  font-size: 14px;
  color: var(--color-text-secondary);
}

.form-field input {
  padding: 12px;
  font-size: 16px;
  border: 1px solid var(--color-border);
  border-radius: 4px;
}
</style>
<!-- Eye flows straight down -->
<!-- Works at any viewport width -->
```

**Label placement rules:**
- Top-aligned labels: Best for most forms (faster completion)
- Inline labels (in field): Only for single fields (search bars)
- Left-aligned labels: Only when vertical space is critical
- Always use `for` attribute linking label to input `id`

Reference: [UX Movement Label Placement](https://uxmovement.com/forms/why-infield-top-aligned-form-labels-are-quickest-to-scan/)
