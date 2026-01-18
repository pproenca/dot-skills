---
title: Use Default Parameters Instead of Conditional Assignment
impact: MEDIUM
impactDescription: clearer API and prevents falsy value bugs
tags: func, default-parameters, parameters, es6
---

## Use Default Parameters Instead of Conditional Assignment

Use default parameter syntax instead of conditionally assigning inside the function body. Defaults appear in the signature and avoid falsy value pitfalls.

**Incorrect (conditional assignment inside body):**

```javascript
function createUser(name, role, isActive) {
  name = name || 'Anonymous';  // '' is falsy, becomes 'Anonymous'
  role = role || 'viewer';
  isActive = isActive !== undefined ? isActive : true;  // Verbose

  return { name, role, isActive };
}

function formatCurrency(amount, currency, locale) {
  if (currency === undefined) {
    currency = 'USD';
  }
  if (locale === undefined) {
    locale = 'en-US';
  }
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}
```

**Correct (default parameters in signature):**

```javascript
function createUser(name = 'Anonymous', role = 'viewer', isActive = true) {
  return { name, role, isActive };
}

function formatCurrency(amount, currency = 'USD', locale = 'en-US') {
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
}

// Allows passing empty string or 0 without triggering default
createUser('', 'admin', false);  // { name: '', role: 'admin', isActive: false }
```

**Rules for default parameters:**
- Place after required parameters
- Keep initializers simple (no side effects)
- Defaults must be provided in concrete implementations (not interfaces)

Reference: [Google JavaScript Style Guide - Default parameters](https://google.github.io/styleguide/jsguide.html#features-default-parameters)
