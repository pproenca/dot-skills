---
title: Use Direct Module Imports Instead of Barrel Files
impact: CRITICAL
impactDescription: 50-80% reduction in imported code
tags: bundle, imports, tree-shaking, barrel-files, metro
---

## Use Direct Module Imports Instead of Barrel Files

Metro bundler lacks tree-shaking. Importing from barrel files (index.js) bundles the entire library. Import directly from module paths.

**Incorrect (imports entire library):**

```tsx
// Imports all 300+ lodash functions
import { debounce, throttle } from 'lodash'

// Imports all date-fns functions
import { format, parseISO } from 'date-fns'

// Imports all icons (1,500+ icons)
import { Home, Settings, User } from '@expo/vector-icons/Feather'
```

**Correct (imports only needed modules):**

```tsx
// Imports only debounce (~2KB instead of ~70KB)
import debounce from 'lodash/debounce'
import throttle from 'lodash/throttle'

// Imports only format and parseISO
import format from 'date-fns/format'
import parseISO from 'date-fns/parseISO'

// Import specific icon
import { Feather } from '@expo/vector-icons'
// Or even better, use specific imports when available
```

**Alternative (use smaller libraries):**

```tsx
// Instead of lodash (70KB)
import debounce from 'lodash.debounce'  // 2KB standalone package

// Instead of moment.js (300KB)
import { formatDistance } from 'date-fns/formatDistance'  // ~5KB

// Instead of full icon library
// Use only the icons you need, consider SVG sprites
```

**Verify with bundle analysis:**

```bash
# Analyze bundle contents
npx react-native-bundle-visualizer

# Or use Expo Atlas
npx expo export --dump-assetmap
```

**Common libraries requiring direct imports:**
- `lodash` → `lodash/functionName`
- `date-fns` → `date-fns/functionName`
- `ramda` → `ramda/src/functionName`
- `rxjs` → `rxjs/operators`

Reference: [Callstack Bundle Optimization Guide](https://www.callstack.com/blog/optimize-react-native-apps-javascript-bundle)
