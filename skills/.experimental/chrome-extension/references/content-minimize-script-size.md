---
title: Minimize Content Script Bundle Size
impact: CRITICAL
impactDescription: reduces page load impact by 100-500ms per page
tags: content, bundle, size, compilation, performance
---

## Minimize Content Script Bundle Size

Content script JavaScript must be parsed and compiled on every page load. Unlike web pages, extension scripts don't benefit from HTTP cache for compilation. Large bundles significantly slow down every page the user visits.

**Incorrect (large monolithic bundle):**

```javascript
// content.js - 200KB bundle with unused code
import React from 'react';           // 40KB
import ReactDOM from 'react-dom';    // 40KB
import lodash from 'lodash';         // 70KB
import moment from 'moment';         // 50KB

// Only uses 2 functions from each library
const result = lodash.debounce(() => {});
const date = moment().format('YYYY-MM-DD');
```

**Correct (minimal targeted imports):**

```javascript
// content.js - 5KB bundle with only what's needed
import debounce from 'lodash/debounce';  // 1KB

// Use native alternatives when possible
const date = new Date().toISOString().split('T')[0];

// Lazy-load heavy features
let heavyModule = null;
async function loadHeavyFeature() {
  if (!heavyModule) {
    heavyModule = await import('./heavy-feature.js');
  }
  return heavyModule;
}
```

**Bundle optimization strategies:**
- Use tree-shakeable ES modules
- Import specific functions, not entire libraries
- Use native APIs instead of libraries (Date vs moment)
- Split code and lazy-load non-critical features
- Analyze bundle with tools like webpack-bundle-analyzer

**Target sizes:**
- Simple content scripts: < 10KB
- Feature-rich scripts: < 50KB
- Heavy UI overlays: lazy-load separately

Reference: [Content Scripts](https://developer.chrome.com/docs/extensions/develop/concepts/content-scripts)
