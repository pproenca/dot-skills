---
title: Never Use Color Alone to Convey Information
impact: MEDIUM
impactDescription: enables 8% of men with color blindness to understand content
tags: color, accessibility, color-blindness, wcag, icons
---

## Never Use Color Alone to Convey Information

Approximately 8% of men and 0.5% of women have color vision deficiency. Using only color to indicate status, errors, or required fields excludes these users from understanding the interface.

**Incorrect (color as only indicator):**

```html
<style>
  .required-field { border-color: red; }
  .success-message { color: green; }
  .error-message { color: red; }
</style>

<form>
  <input class="required-field" name="email">
  <span class="error-message">Invalid email</span>
</form>

<div class="chart-legend">
  <span style="color: green;">Sales</span>
  <span style="color: red;">Returns</span>
</div>
<!-- Color-blind users cannot distinguish green from red -->
```

**Correct (color plus additional indicators):**

```html
<style>
  .required-field {
    border-color: #d32f2f;
    border-width: 2px;
  }
  .required-field::after {
    content: "*";
  }

  .success-message {
    color: #2e7d32;
  }
  .success-message::before {
    content: "✓ ";
  }

  .error-message {
    color: #d32f2f;
  }
  .error-message::before {
    content: "⚠ ";
  }
</style>

<form>
  <label>Email <span class="required-asterisk">*</span></label>
  <input class="required-field" name="email" aria-required="true">
  <span class="error-message">⚠ Invalid email format</span>
</form>

<div class="chart-legend">
  <span><span class="icon-circle-fill"></span> Sales</span>
  <span><span class="icon-circle-outline"></span> Returns</span>
</div>
<!-- Color + icon/text provides redundant information -->
```

**Redundant indicators:**
- Icons (✓, ⚠, ✗) alongside colored text
- Patterns or shapes in charts/graphs
- Text labels ("Required", "Error", "Success")
- Underlines, borders, or other visual treatments

Reference: [WCAG Use of Color](https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html)
