---
title: Maintain Consistent Visual Style
impact: LOW-MEDIUM
impactDescription: builds brand recognition and professional appearance
tags: brand, consistency, styling, design-system, visual-identity
---

## Maintain Consistent Visual Style

Apply consistent colors, typography, and spacing across all extension surfaces (popup, side panel, options, injected UI). Inconsistent styling looks unprofessional and confuses users.

**Incorrect (inconsistent styling):**

```css
/* popup.css */
.btn { background: #007bff; border-radius: 4px; font-size: 14px; }

/* options.css */
.button { background: #0066cc; border-radius: 8px; font-size: 16px; }

/* content.css */
.action-btn { background: blue; border-radius: 0; font-size: 12px; }

/* Three different blues, three different radii, three different sizes */
```

**Correct (unified design system):**

```css
/* shared/variables.css - Single source of truth */
:root {
  /* Brand colors */
  --color-primary: #4A90D9;
  --color-primary-hover: #357ABD;
  --color-primary-active: #2868A8;

  --color-success: #28a745;
  --color-warning: #ffc107;
  --color-error: #dc3545;

  /* Neutrals */
  --color-text: #333333;
  --color-text-secondary: #666666;
  --color-border: #e0e0e0;
  --color-background: #ffffff;
  --color-background-secondary: #f5f5f5;

  /* Typography */
  --font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-size-small: 12px;
  --font-size-base: 14px;
  --font-size-large: 16px;

  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;

  /* Borders */
  --border-radius: 6px;
  --border-width: 1px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.1);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* shared/components.css - Reusable components */
.btn {
  padding: var(--spacing-sm) var(--spacing-md);
  font-family: var(--font-family);
  font-size: var(--font-size-base);
  border-radius: var(--border-radius);
  border: none;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.btn-primary {
  background: var(--color-primary);
  color: white;
}

.btn-primary:hover {
  background: var(--color-primary-hover);
}

.btn-primary:active {
  background: var(--color-primary-active);
}
```

**Using the design system:**

```html
<!-- popup.html -->
<link rel="stylesheet" href="shared/variables.css">
<link rel="stylesheet" href="shared/components.css">
<link rel="stylesheet" href="popup.css">

<!-- options.html -->
<link rel="stylesheet" href="shared/variables.css">
<link rel="stylesheet" href="shared/components.css">
<link rel="stylesheet" href="options.css">
```

**For Shadow DOM (content scripts):**

```typescript
// content.js - Include design system in Shadow DOM
const styles = await fetch(chrome.runtime.getURL('shared/variables.css')).then(r => r.text())
const components = await fetch(chrome.runtime.getURL('shared/components.css')).then(r => r.text())

const shadow = host.attachShadow({ mode: 'closed' })
shadow.innerHTML = `
  <style>${styles}\n${components}</style>
  <div class="extension-ui">
    <button class="btn btn-primary">Save</button>
  </div>
`
```

Reference: [Web Content Accessibility Guidelines - Consistency](https://www.w3.org/WAI/WCAG21/Understanding/consistent-identification.html)
