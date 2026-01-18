---
title: Use Relative Paths for Project Imports
impact: HIGH
impactDescription: improves refactoring flexibility and reduces coupling
tags: module, imports, paths, organization
---

## Use Relative Paths for Project Imports

Use relative paths (`./foo`) for imports within your project to maintain flexibility when moving code between directories.

**Incorrect (absolute or alias paths for local code):**

```typescript
// Tightly coupled to project structure
import { User } from '@app/models/user'
import { createUser } from 'src/services/user-service'
```

**Correct (relative paths):**

```typescript
// Flexible, works when files are moved together
import { User } from './models/user'
import { createUser } from '../services/user-service'
```

**When to use non-relative imports:**
- External npm packages: `import { useState } from 'react'`
- Configured path aliases for truly shared code
- Generated code or type definitions

**Benefits:**
- Files can be moved together without breaking imports
- No build configuration required
- Clear dependency direction visible in path

Reference: [Google TypeScript Style Guide - Module imports](https://google.github.io/styleguide/tsguide.html#imports)
