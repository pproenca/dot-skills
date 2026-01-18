---
title: Include File Extension in Import Paths
impact: CRITICAL
impactDescription: prevents module resolution failures
tags: module, imports, file-extension, es-modules
---

## Include File Extension in Import Paths

ES module import paths must include the `.js` file extension. Omitting extensions causes resolution failures in browsers and strict ESM environments.

**Incorrect (missing file extension):**

```javascript
// main.js
import { validateEmail } from './validators';  // Fails in browser ESM
import { formatDate } from './utils/dateFormatter';

export function processUserInput(email, date) {
  if (!validateEmail(email)) {
    throw new Error('Invalid email');
  }
  return formatDate(date);
}
```

**Correct (explicit file extensions):**

```javascript
// main.js
import { validateEmail } from './validators.js';
import { formatDate } from './utils/dateFormatter.js';

export function processUserInput(email, date) {
  if (!validateEmail(email)) {
    throw new Error('Invalid email');
  }
  return formatDate(date);
}
```

**Note:** Some bundlers (webpack, Vite) auto-resolve extensions during build, but native ESM and Closure Compiler require explicit extensions.

Reference: [Google JavaScript Style Guide - ES module imports](https://google.github.io/styleguide/jsguide.html#es-module-imports)
