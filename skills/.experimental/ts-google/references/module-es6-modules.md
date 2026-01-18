---
title: Use ES6 Modules Exclusively
impact: CRITICAL
impactDescription: enables tree-shaking and static analysis
tags: module, es6, imports, commonjs
---

## Use ES6 Modules Exclusively

ES6 modules enable static analysis, tree-shaking, and consistent behavior across environments. Never use legacy module systems.

**Incorrect (legacy patterns):**

```typescript
// CommonJS - no static analysis possible
const fs = require('fs')

// TypeScript namespaces - creates runtime overhead
namespace MyApp {
  export class User {}
}

// Triple-slash references - fragile path resolution
/// <reference path="./types.d.ts" />
```

**Correct (ES6 modules):**

```typescript
// Named imports
import { readFile, writeFile } from 'fs'

// Namespace imports for large APIs
import * as fs from 'fs'

// Side-effect imports (use sparingly)
import './polyfills'
```

**When to use each import style:**
- Named imports: accessing few symbols frequently
- Namespace imports: accessing many symbols from large APIs
- Side-effect imports: libraries requiring initialization

Reference: [Google TypeScript Style Guide - Imports](https://google.github.io/styleguide/tsguide.html#imports)
