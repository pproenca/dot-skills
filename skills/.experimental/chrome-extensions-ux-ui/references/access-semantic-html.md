---
title: Use Semantic HTML Elements
impact: CRITICAL
impactDescription: built-in keyboard and screen reader support
tags: access, semantic, html, native-elements, accessibility
---

## Use Semantic HTML Elements

Use native HTML elements (`<button>`, `<input>`, `<select>`) instead of styled `<div>` or `<span>` elements for interactive components. Native elements provide keyboard support and screen reader announcements automatically.

**Incorrect (div-based interactive elements):**

```html
<!-- popup.html - Requires manual accessibility implementation -->
<div class="btn primary" onclick="handleSubmit()">
  Submit
</div>

<div class="checkbox" onclick="toggleCheck()">
  <span class="check-icon"></span>
  Enable notifications
</div>

<div class="dropdown" onclick="openOptions()">
  <span class="selected">Choose option</span>
  <span class="arrow"></span>
</div>
<!-- No keyboard support, no screen reader roles, no form integration -->
```

**Correct (native HTML elements):**

```html
<!-- popup.html - Accessibility built-in -->
<button type="submit" class="btn primary">
  Submit
</button>

<label class="checkbox">
  <input type="checkbox" name="notifications">
  <span class="check-icon" aria-hidden="true"></span>
  Enable notifications
</label>

<select class="dropdown" name="option">
  <option value="">Choose option</option>
  <option value="1">Option 1</option>
  <option value="2">Option 2</option>
</select>
<!-- Keyboard accessible, screen reader compatible, form-ready -->
```

**Native element benefits:**

| Native Element | Built-in Features |
|----------------|-------------------|
| `<button>` | Focus, Enter/Space activation, disabled state |
| `<input type="checkbox">` | Toggle with Space, checked state announced |
| `<select>` | Arrow key navigation, type-ahead search |
| `<a href>` | Focus, Enter activation, visited state |
| `<input type="text">` | Text editing, form validation, autocomplete |

**When custom components are unavoidable:**

```html
<!-- Add ALL required ARIA attributes and keyboard handlers -->
<div role="checkbox"
     tabindex="0"
     aria-checked="false"
     aria-labelledby="notif-label"
     onkeydown="handleCheckboxKeydown(event)"
     onclick="toggleCheck()">
  <span class="check-icon" aria-hidden="true"></span>
</div>
<span id="notif-label">Enable notifications</span>
```

Reference: [Using ARIA](https://www.w3.org/WAI/ARIA/apg/practices/read-me-first/)
