---
title: Choose Correct Array Parser Format
impact: CRITICAL
impactDescription: determines URL format and compatibility with backend APIs
tags: parser, parseAsArrayOf, parseAsNativeArrayOf, arrays, url-format
---

## Choose Correct Array Parser Format

nuqs offers two array formats with different URL representations. Choose based on your backend API expectations and URL readability requirements.

**parseAsArrayOf (comma-separated):**

```tsx
'use client'
import { useQueryState, parseAsArrayOf, parseAsInteger } from 'nuqs'

export default function MultiSelect() {
  const [ids, setIds] = useQueryState(
    'ids',
    parseAsArrayOf(parseAsInteger).withDefault([])
  )
  // URL: ?ids=1,2,3
  // State: [1, 2, 3]

  return (
    <div>
      Selected: {ids.join(', ')}
      <button onClick={() => setIds([...ids, ids.length + 1])}>
        Add
      </button>
    </div>
  )
}
```

**parseAsNativeArrayOf (repeated params):**

```tsx
'use client'
import { useQueryState, parseAsNativeArrayOf, parseAsString } from 'nuqs'

export default function TagFilter() {
  const [tags, setTags] = useQueryState(
    'tag',
    parseAsNativeArrayOf(parseAsString).withDefault([])
  )
  // URL: ?tag=react&tag=nextjs&tag=typescript
  // State: ['react', 'nextjs', 'typescript']

  return (
    <div>
      Tags: {tags.join(', ')}
      <button onClick={() => setTags([...tags, 'new-tag'])}>
        Add Tag
      </button>
    </div>
  )
}
```

**When to use each:**

| Format | URL Example | Use When |
|--------|-------------|----------|
| `parseAsArrayOf` | `?ids=1,2,3` | Compact URLs, numeric IDs |
| `parseAsNativeArrayOf` | `?tag=a&tag=b` | Backend expects repeated params, standard form encoding |

**Incorrect (wrong format for API):**

```tsx
// Backend expects: ?tag=a&tag=b
const [tags] = useQueryState('tags', parseAsArrayOf(parseAsString))
// Sends: ?tags=a,b - backend gets single string "a,b"
```

Reference: [nuqs Array Parsers](https://nuqs.dev/docs/parsers)
