---
title: Validate JSON Parser Input
impact: CRITICAL
impactDescription: prevents runtime crashes from malformed URL data
tags: parser, parseAsJson, validation, type-guard, security
---

## Validate JSON Parser Input

`parseAsJson` accepts a validation function. Without validation, malformed or malicious JSON in the URL causes runtime errors or security issues.

**Incorrect (no validation):**

```tsx
'use client'
import { useQueryState, parseAsJson } from 'nuqs'

interface Filters {
  minPrice: number
  maxPrice: number
  categories: string[]
}

export default function FilterPanel() {
  const [filters, setFilters] = useQueryState(
    'filters',
    parseAsJson<Filters>() // No validation!
  )
  // URL: ?filters={"malicious":true} passes through
  // URL: ?filters=notjson crashes

  return <div>{filters?.minPrice}</div>
}
```

**Correct (with validation):**

```tsx
'use client'
import { useQueryState, parseAsJson } from 'nuqs'

interface Filters {
  minPrice: number
  maxPrice: number
  categories: string[]
}

function isValidFilters(value: unknown): value is Filters {
  if (!value || typeof value !== 'object') return false
  const obj = value as Record<string, unknown>
  return (
    typeof obj.minPrice === 'number' &&
    typeof obj.maxPrice === 'number' &&
    Array.isArray(obj.categories) &&
    obj.categories.every(c => typeof c === 'string')
  )
}

export default function FilterPanel() {
  const [filters, setFilters] = useQueryState(
    'filters',
    parseAsJson<Filters>(isValidFilters).withDefault({
      minPrice: 0,
      maxPrice: 1000,
      categories: []
    })
  )
  // Invalid JSON returns null, falls back to default

  return (
    <div>
      Price: {filters.minPrice} - {filters.maxPrice}
    </div>
  )
}
```

**Alternative (with Zod):**

```tsx
import { z } from 'zod'

const FiltersSchema = z.object({
  minPrice: z.number(),
  maxPrice: z.number(),
  categories: z.array(z.string())
})

const [filters, setFilters] = useQueryState(
  'filters',
  parseAsJson<z.infer<typeof FiltersSchema>>(
    (value) => FiltersSchema.safeParse(value).success ? value : null
  )
)
```

Reference: [nuqs JSON Parser](https://nuqs.dev/docs/parsers)
