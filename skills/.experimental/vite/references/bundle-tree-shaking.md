---
title: Enable Effective Tree-Shaking
impact: HIGH
impactDescription: removes 20-60% of unused code
tags: bundle, tree-shaking, dead-code, esm
---

## Enable Effective Tree-Shaking

Tree-shaking removes unused code from the bundle. Ensure your dependencies support ESM and avoid patterns that prevent tree-shaking.

**Incorrect (prevents tree-shaking):**

```javascript
// Importing entire library
import _ from 'lodash'
const result = _.get(obj, 'path')

// CommonJS default export
const utils = require('./utils')

// Side-effect imports without sideEffects flag
import './analytics'
```

**Correct (tree-shakeable):**

```javascript
// Named imports from ESM
import { get } from 'lodash-es'
const result = get(obj, 'path')

// ESM imports
import { helper } from './utils'

// Mark side-effect-free in package.json
```

```json
// package.json
{
  "sideEffects": false,
  // Or specify files with side effects
  "sideEffects": ["*.css", "./src/analytics.js"]
}
```

**Verify tree-shaking:**

```bash
# Check what's included
vite build --debug
# Or use bundle analyzer
```

**Dependencies to replace:**
- `lodash` → `lodash-es`
- `moment` → `date-fns`
- `rxjs` → `rxjs` (use pipeable operators)

Reference: [Building for Production](https://vite.dev/guide/build)
