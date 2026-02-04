---
title: Use tailwind-merge for Class Deduplication
impact: MEDIUM
impactDescription: prevents conflicting utilities from both applying
tags: perf, tailwind-merge, deduplication, conflicts
---

## Use tailwind-merge for Class Deduplication

Uniwind doesn't automatically deduplicate conflicting utilities. Use `tailwind-merge` to ensure only the last conflicting class applies.

**Incorrect (both classes apply based on CSS specificity):**

```tsx
function Card({ className }: { className?: string }) {
  // Both bg-card AND bg-red-500 may apply!
  return (
    <View className={`bg-card p-4 rounded ${className}`}>
      <Text>Content</Text>
    </View>
  )
}

// Usage - unpredictable which background wins
<Card className="bg-red-500" />
```

**Correct (using tailwind-merge):**

```tsx
import { twMerge } from 'tailwind-merge'

function Card({ className }: { className?: string }) {
  return (
    <View className={twMerge('bg-card p-4 rounded', className)}>
      <Text>Content</Text>
    </View>
  )
}

// Usage - bg-red-500 correctly overrides bg-card
<Card className="bg-red-500" />
```

**When to use tailwind-merge:**
- Components that accept className prop for overrides
- Composing multiple class sources
- Building component libraries

**Performance tip:** twMerge has minimal overhead for typical use cases.

```bash
npm install tailwind-merge
```

Reference: [Uniwind Migration Guide](https://docs.uniwind.dev/migration-from-nativewind)
