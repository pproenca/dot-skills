---
title: Import from Stable Public APIs Only
impact: MEDIUM-HIGH
impactDescription: prevents breakage from internal refactoring, clarifies module boundaries
tags: couple, imports, public-api, encapsulation, stability
---

## Import from Stable Public APIs Only

Importing from internal file paths creates coupling to implementation details. Import from public index files to enable internal refactoring.

**Code Smell Indicators:**
- Deep imports like `from '../components/Button/utils/helpers'`
- Refactoring file locations breaks consumers
- Unclear what's public vs internal
- Barrel file exports everything

**Incorrect (deep imports create coupling):**

```tsx
// Deep imports couple to internal structure
import { Button } from '@/features/ui/components/Button/Button'
import { formatDate } from '@/features/ui/components/DatePicker/utils/formatters'
import { useButtonStyles } from '@/features/ui/components/Button/hooks/useButtonStyles'

// If Button.tsx moves or is renamed, all consumers break
// If formatDate is refactored into DatePicker, imports break
// useButtonStyles is internal but exposed through path
```

**Correct (import from public API):**

```tsx
// features/ui/index.ts - explicit public API
export { Button } from './components/Button'
export { DatePicker } from './components/DatePicker'
export type { ButtonProps, DatePickerProps } from './types'

// Don't export internal utilities
// Don't export internal hooks

// Consumer imports from public API only
import { Button, DatePicker } from '@/features/ui'

// Internal changes don't break consumers
```

**Feature module structure:**

```
features/ui/
├── index.ts                 # Public API - only import from here
├── types.ts                 # Public types
├── components/
│   ├── Button/
│   │   ├── index.ts        # Component's public API
│   │   ├── Button.tsx      # Implementation
│   │   ├── Button.css      # Internal
│   │   └── hooks/          # Internal hooks
│   │       └── useButtonStyles.ts
│   └── DatePicker/
│       ├── index.ts
│       ├── DatePicker.tsx
│       └── utils/          # Internal utils
│           └── formatters.ts
└── internal/               # Explicitly internal (optional convention)
    └── sharedUtils.ts
```

**Component's index.ts:**

```tsx
// components/Button/index.ts
export { Button } from './Button'
export type { ButtonProps } from './Button'

// Internal hooks and utils not exported
```

**ESLint to enforce:**

```js
// eslint.config.js
{
  rules: {
    'no-restricted-imports': ['error', {
      patterns: [
        {
          group: ['@/features/*/components/*/*'],
          message: 'Import from feature index, not internal paths',
        },
        {
          group: ['@/features/*/internal/*'],
          message: 'Internal modules are not for external use',
        },
      ],
    }],
  },
}
```

**TypeScript paths for enforcement:**

```json
// tsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/features/*": ["src/features/*/index.ts"],
      // No path for internal files - they can't be imported externally
    }
  }
}
```

**Benefits:**
- Refactor internals without breaking consumers
- Clear boundaries between modules
- Smaller public API surface
- Better tree-shaking (unused internals excluded)

Reference: [Package by Feature](https://phauer.com/2020/package-by-feature/)
