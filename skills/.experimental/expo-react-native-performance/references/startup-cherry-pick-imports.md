---
title: Use Direct Imports Instead of Barrel Files
impact: CRITICAL
impactDescription: reduces bundle by 100KB-1MB per library
tags: startup, bundle, imports, tree-shaking
---

## Use Direct Imports Instead of Barrel Files

Metro bundler doesn't tree-shake effectively. Importing from barrel files (index.js) pulls in entire libraries. Always import directly from the specific module path to include only what you need.

**Incorrect (imports entire lodash library):**

```typescript
// utils/data.ts
import { debounce, throttle } from 'lodash';
// Bundles all 600KB of lodash even though you use 2 functions

export const debouncedSearch = debounce(searchUsers, 300);
export const throttledScroll = throttle(handleScroll, 100);
```

**Correct (imports only used functions):**

```typescript
// utils/data.ts
import debounce from 'lodash/debounce';
import throttle from 'lodash/throttle';
// Bundles only ~2KB for the two functions

export const debouncedSearch = debounce(searchUsers, 300);
export const throttledScroll = throttle(handleScroll, 100);
```

**Common libraries requiring cherry-picking:**

| Library | Bad Import | Good Import |
|---------|------------|-------------|
| lodash | `from 'lodash'` | `from 'lodash/debounce'` |
| date-fns | `from 'date-fns'` | `from 'date-fns/format'` |
| @expo/vector-icons | `from '@expo/vector-icons'` | `from '@expo/vector-icons/Ionicons'` |

**Alternative:** Use `babel-plugin-lodash` or `babel-plugin-date-fns` for automatic transforms.

Reference: [Callstack Bundle Optimization](https://www.callstack.com/blog/optimize-react-native-apps-javascript-bundle)
