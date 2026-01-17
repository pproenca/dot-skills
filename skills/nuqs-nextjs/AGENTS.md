# nuqs

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for nuqs (type-safe URL query state management) in Next.js applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (parser configuration, adapter setup) to incremental (advanced patterns). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Parser Configuration](#1-parser-configuration) — **CRITICAL**
   - 1.1 [Choose Correct Array Parser Format](#11-choose-correct-array-parser-format)
   - 1.2 [Select Appropriate Date Parser](#12-select-appropriate-date-parser)
   - 1.3 [Use Enum Parsers for Constrained Values](#13-use-enum-parsers-for-constrained-values)
   - 1.4 [Use parseAsHex for Color Values](#14-use-parseashex-for-color-values)
   - 1.5 [Use parseAsIndex for 1-Based URL Display](#15-use-parseasindex-for-1-based-url-display)
   - 1.6 [Use Typed Parsers for Non-String Values](#16-use-typed-parsers-for-non-string-values)
   - 1.7 [Use withDefault for Non-Nullable State](#17-use-withdefault-for-non-nullable-state)
   - 1.8 [Validate JSON Parser Input](#18-validate-json-parser-input)
2. [Adapter & Setup](#2-adapter-setup) — **CRITICAL**
   - 2.1 [Add 'use client' Directive for Hooks](#21-add-use-client-directive-for-hooks)
   - 2.2 [Define Shared Parsers in Dedicated File](#22-define-shared-parsers-in-dedicated-file)
   - 2.3 [Ensure Compatible Next.js Version](#23-ensure-compatible-nextjs-version)
   - 2.4 [Import Server Utilities from nuqs/server](#24-import-server-utilities-from-nuqsserver)
   - 2.5 [Wrap App with NuqsAdapter](#25-wrap-app-with-nuqsadapter)
3. [State Management](#3-state-management) — **HIGH**
   - 3.1 [Avoid Derived State from URL Parameters](#31-avoid-derived-state-from-url-parameters)
   - 3.2 [Clear URL Parameters with null](#32-clear-url-parameters-with-null)
   - 3.3 [Handle Controlled Input Value Properly](#33-handle-controlled-input-value-properly)
   - 3.4 [Use Functional Updates for State Derived from Previous Value](#34-use-functional-updates-for-state-derived-from-previous-value)
   - 3.5 [Use Setter Return Value for URL Access](#35-use-setter-return-value-for-url-access)
   - 3.6 [Use useQueryStates for Related Parameters](#36-use-usequerystates-for-related-parameters)
   - 3.7 [Use withOptions for Parser-Level Configuration](#37-use-withoptions-for-parser-level-configuration)
4. [Server Integration](#4-server-integration) — **HIGH**
   - 4.1 [Call parse() Before get() in Server Components](#41-call-parse-before-get-in-server-components)
   - 4.2 [Handle Async searchParams in Next.js 15+](#42-handle-async-searchparams-in-nextjs-15)
   - 4.3 [Integrate useTransition for Loading States](#43-integrate-usetransition-for-loading-states)
   - 4.4 [Share Parsers Between Client and Server](#44-share-parsers-between-client-and-server)
   - 4.5 [Use createSearchParamsCache for Server Components](#45-use-createsearchparamscache-for-server-components)
   - 4.6 [Use shallow:false to Trigger Server Re-renders](#46-use-shallowfalse-to-trigger-server-re-renders)
5. [Performance Optimization](#5-performance-optimization) — **MEDIUM**
   - 5.1 [Debounce Search Input Before URL Update](#51-debounce-search-input-before-url-update)
   - 5.2 [Memoize Components Using URL State](#52-memoize-components-using-url-state)
   - 5.3 [Throttle Rapid URL Updates](#53-throttle-rapid-url-updates)
   - 5.4 [Use clearOnDefault for Clean URLs](#54-use-clearondefault-for-clean-urls)
   - 5.5 [Use createSerializer for Link URLs](#55-use-createserializer-for-link-urls)
6. [History & Navigation](#6-history-navigation) — **MEDIUM**
   - 6.1 [Control Scroll Behavior on URL Changes](#61-control-scroll-behavior-on-url-changes)
   - 6.2 [Handle Browser Back/Forward Navigation](#62-handle-browser-backforward-navigation)
   - 6.3 [Use history:push for Navigation-Like State](#63-use-historypush-for-navigation-like-state)
   - 6.4 [Use history:replace for Ephemeral State](#64-use-historyreplace-for-ephemeral-state)
7. [Debugging & Testing](#7-debugging-testing) — **LOW-MEDIUM**
   - 7.1 [Diagnose Common nuqs Errors](#71-diagnose-common-nuqs-errors)
   - 7.2 [Enable Debug Logging for Troubleshooting](#72-enable-debug-logging-for-troubleshooting)
   - 7.3 [Test Components with URL State](#73-test-components-with-url-state)
8. [Advanced Patterns](#8-advanced-patterns) — **LOW**
   - 8.1 [Create Custom Parsers for Complex Types](#81-create-custom-parsers-for-complex-types)
   - 8.2 [Implement eq Function for Object Parsers](#82-implement-eq-function-for-object-parsers)
   - 8.3 [Use Framework-Specific Adapters](#83-use-framework-specific-adapters)
   - 8.4 [Use urlKeys for Shorter URLs](#84-use-urlkeys-for-shorter-urls)

---

## 1. Parser Configuration

**Impact: CRITICAL**

Incorrect parsers cause type mismatches, runtime errors, and hydration failures. Parser selection cascades through the entire state lifecycle.

### 1.1 Choose Correct Array Parser Format

**Impact: CRITICAL (prevents API integration failures from wrong URL format)**

nuqs offers two array formats with different URL representations. Choose based on your backend API expectations and URL readability requirements.

**Incorrect (wrong format for backend):**

```tsx
'use client'
import { useQueryState, parseAsArrayOf, parseAsString } from 'nuqs'

export default function TagFilter() {
  const [tags, setTags] = useQueryState(
    'tags',
    parseAsArrayOf(parseAsString).withDefault([])
  )
  // URL: ?tags=react,nextjs
  // But backend expects: ?tag=react&tag=nextjs
  // API receives single string "react,nextjs" instead of array!
}
```

**Correct (match backend expectations):**

```tsx
'use client'
import { useQueryState, parseAsNativeArrayOf, parseAsString } from 'nuqs'

export default function TagFilter() {
  const [tags, setTags] = useQueryState(
    'tag', // Note: singular key name
    parseAsNativeArrayOf(parseAsString).withDefault([])
  )
  // URL: ?tag=react&tag=nextjs
  // Backend correctly receives array ['react', 'nextjs']

  return (
    <div>
      Tags: {tags.join(', ')}
      <button onClick={() => setTags([...tags, 'new-tag'])}>Add</button>
    </div>
  )
}
```

**When to use each:**

| Format | URL Example | Use When |
|--------|-------------|----------|
| `parseAsArrayOf` | `?ids=1,2,3` | Compact URLs, numeric IDs, custom backends |
| `parseAsNativeArrayOf` | `?tag=a&tag=b` | Standard form encoding, PHP/Rails backends |

Reference: [nuqs Array Parsers](https://nuqs.dev/docs/parsers)

### 1.2 Select Appropriate Date Parser

**Impact: CRITICAL (prevents timezone bugs and parsing failures)**

nuqs provides three date parsers with different URL formats and precision. Choose based on your requirements for time precision and URL readability.

**Incorrect (wrong parser for use case):**

```tsx
'use client'
import { useQueryState, parseAsIsoDateTime } from 'nuqs'

export default function DateRangePicker() {
  const [startDate, setStartDate] = useQueryState('start', parseAsIsoDateTime)
  // URL: ?start=2024-01-01T00:00:00.000Z
  // Problem: User selected "Jan 1" but URL shows timezone complexity
  // Better: Use parseAsIsoDate for date-only pickers

  return (
    <input
      type="date"
      value={startDate?.toISOString().slice(0, 10) ?? ''}
      onChange={e => setStartDate(new Date(e.target.value))}
    />
  )
}
```

**Correct (match parser to use case):**

```tsx
'use client'
import { useQueryState, parseAsIsoDate, parseAsTimestamp } from 'nuqs'

export default function DateRangePicker() {
  // For date-only picker: clean URL
  const [startDate, setStartDate] = useQueryState('start', parseAsIsoDate)
  // URL: ?start=2024-01-01

  // For precise timestamps: use parseAsTimestamp
  const [lastModified, setLastModified] = useQueryState('modified', parseAsTimestamp)
  // URL: ?modified=1704067200000

  return (
    <input
      type="date"
      value={startDate?.toISOString().slice(0, 10) ?? ''}
      onChange={e => setStartDate(new Date(e.target.value))}
    />
  )
}
```

**When to use each:**

| Parser | URL Format | Use Case |
|--------|------------|----------|
| `parseAsTimestamp` | `1704067200000` | Precise timestamps, API integration |
| `parseAsIsoDateTime` | `2024-01-01T12:00:00.000Z` | Debugging, shareable URLs with time |
| `parseAsIsoDate` | `2024-01-01` | Date pickers, calendar views |

Reference: [nuqs Date Parsers](https://nuqs.dev/docs/parsers)

### 1.3 Use Enum Parsers for Constrained Values

**Impact: CRITICAL (prevents invalid state from URL manipulation)**

When state should only accept specific values (like status, sort direction, or view mode), use enum or literal parsers. This prevents invalid values from URL tampering and provides type safety.

**Incorrect (accepts any string):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

type SortOrder = 'asc' | 'desc'

export default function SortableList() {
  const [sort, setSort] = useQueryState('sort')
  // sort is string | null - accepts ANY value
  // URL: ?sort=malicious works silently

  const sortOrder = sort as SortOrder // Unsafe cast!

  return (
    <select
      value={sort ?? 'asc'}
      onChange={e => setSort(e.target.value)}
    >
      <option value="asc">Ascending</option>
      <option value="desc">Descending</option>
    </select>
  )
}
```

**Correct (validated enum):**

```tsx
'use client'
import { useQueryState, parseAsStringLiteral } from 'nuqs'

const sortOrders = ['asc', 'desc'] as const

export default function SortableList() {
  const [sort, setSort] = useQueryState(
    'sort',
    parseAsStringLiteral(sortOrders).withDefault('asc')
  )
  // sort is 'asc' | 'desc' - invalid values return null/default
  // URL: ?sort=malicious → falls back to 'asc'

  return (
    <select value={sort} onChange={e => setSort(e.target.value as typeof sort)}>
      <option value="asc">Ascending</option>
      <option value="desc">Descending</option>
    </select>
  )
}
```

**Alternative (TypeScript enum):**

```tsx
import { parseAsStringEnum } from 'nuqs'

enum Status {
  Active = 'active',
  Inactive = 'inactive',
  Pending = 'pending'
}

const [status, setStatus] = useQueryState(
  'status',
  parseAsStringEnum<Status>(Object.values(Status)).withDefault(Status.Active)
)
```

Reference: [nuqs Enum Parsers](https://nuqs.dev/docs/parsers)

### 1.4 Use parseAsHex for Color Values

**Impact: MEDIUM (50% shorter URLs for color parameters)**

When storing color values in URLs, `parseAsHex` provides cleaner hexadecimal representation instead of decimal numbers.

**Incorrect (decimal in URL):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function ColorPicker() {
  const [color, setColor] = useQueryState(
    'color',
    parseAsInteger.withDefault(0xff0000)
  )
  // URL: ?color=16711680 (not human-readable)

  const hexString = color.toString(16).padStart(6, '0')

  return (
    <input
      type="color"
      value={`#${hexString}`}
      onChange={e => setColor(parseInt(e.target.value.slice(1), 16))}
    />
  )
}
```

**Correct (hex in URL):**

```tsx
'use client'
import { useQueryState, parseAsHex } from 'nuqs'

export default function ColorPicker() {
  const [color, setColor] = useQueryState(
    'color',
    parseAsHex.withDefault(0xff0000)
  )
  // URL: ?color=ff0000 (human-readable)
  // State: 16711680 (number for calculations)

  const hexString = color.toString(16).padStart(6, '0')

  return (
    <input
      type="color"
      value={`#${hexString}`}
      onChange={e => setColor(parseInt(e.target.value.slice(1), 16))}
    />
  )
}
```

**Benefits:**
- URLs are readable: `?color=ff0000` vs `?color=16711680`
- State is numeric for calculations
- Standard hex color format in URL

Reference: [nuqs parseAsHex](https://nuqs.dev/docs/parsers)

### 1.5 Use parseAsIndex for 1-Based URL Display

**Impact: HIGH (eliminates off-by-one errors between URL and code)**

Arrays are 0-indexed in JavaScript, but users expect 1-indexed URLs (page 1, item 1). `parseAsIndex` automatically converts between them.

**Incorrect (manual conversion):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // URL: ?page=1
  // Array index: need page - 1 everywhere

  const items = ['a', 'b', 'c', 'd', 'e']
  const currentItem = items[page - 1] // Manual conversion

  return (
    <div>
      <p>Page {page}: {currentItem}</p>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </div>
  )
}
```

**Correct (automatic conversion):**

```tsx
'use client'
import { useQueryState, parseAsIndex } from 'nuqs'

export default function Pagination() {
  const [pageIndex, setPageIndex] = useQueryState(
    'page',
    parseAsIndex.withDefault(0)
  )
  // URL: ?page=1 (user-friendly, 1-indexed)
  // State: 0 (code-friendly, 0-indexed)

  const items = ['a', 'b', 'c', 'd', 'e']
  const currentItem = items[pageIndex] // Direct array access

  return (
    <div>
      <p>Page {pageIndex + 1}: {currentItem}</p>
      <button onClick={() => setPageIndex(i => i + 1)}>Next</button>
    </div>
  )
}
```

**How it works:**
- URL `?page=1` → State `0`
- URL `?page=5` → State `4`
- State `0` → URL `?page=1`
- State `4` → URL `?page=5`

**Benefits:**
- No off-by-one bugs
- Array indices work directly
- URLs are human-friendly

Reference: [nuqs parseAsIndex](https://nuqs.dev/docs/parsers)

### 1.6 Use Typed Parsers for Non-String Values

**Impact: CRITICAL (prevents runtime type errors and hydration mismatches)**

URL query parameters are always strings. Without typed parsers, you'll get string values where you expect numbers or booleans, causing type errors and incorrect comparisons.

**Incorrect (string instead of number):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page')
  // page is string | null, not number
  // page + 1 = "11" not 2 when page is "1"

  return (
    <button onClick={() => setPage(String(Number(page) + 1))}>
      Next Page
    </button>
  )
}
```

**Correct (typed parser):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger)
  // page is number | null
  // Arithmetic works correctly

  return (
    <button onClick={() => setPage((p) => (p ?? 0) + 1)}>
      Next Page
    </button>
  )
}
```

**Available parsers:**
- `parseAsInteger` - integers
- `parseAsFloat` - decimal numbers
- `parseAsBoolean` - true/false
- `parseAsTimestamp` - Date from milliseconds
- `parseAsIsoDateTime` - Date from ISO string
- `parseAsJson<T>()` - JSON objects

Reference: [nuqs Parsers Documentation](https://nuqs.dev/docs/parsers)

### 1.7 Use withDefault for Non-Nullable State

**Impact: CRITICAL (eliminates null checks throughout component tree)**

Without `withDefault`, query state is always nullable (`T | null`). This forces null checks everywhere the value is used. Use `withDefault` to provide a fallback value and get non-nullable types.

**Incorrect (nullable state, null checks everywhere):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger)
  // count is number | null

  return (
    <div>
      {/* Null check required */}
      <p>Count: {count ?? 0}</p>
      {/* Null check required */}
      <button onClick={() => setCount((count ?? 0) + 1)}>
        Increment
      </button>
    </div>
  )
}
```

**Correct (non-nullable with default):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState(
    'count',
    parseAsInteger.withDefault(0)
  )
  // count is number (never null)

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(c => c + 1)}>
        Increment
      </button>
    </div>
  )
}
```

**Benefits:**
- TypeScript infers non-nullable type
- No null coalescing needed
- Functional updates work without null checks
- Default appears in URL only when `clearOnDefault: false`

Reference: [nuqs withDefault](https://nuqs.dev/docs/parsers)

### 1.8 Validate JSON Parser Input

**Impact: CRITICAL (prevents runtime crashes from malformed URL data)**

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

---

## 2. Adapter & Setup

**Impact: CRITICAL**

Missing NuqsAdapter or incorrect setup causes hooks to fail silently or throw. Foundation for all nuqs functionality.

### 2.1 Add 'use client' Directive for Hooks

**Impact: CRITICAL (prevents build-breaking hook errors in RSC)**

`useQueryState` and `useQueryStates` are React hooks that require client-side rendering. Using them in Server Components causes build errors.

**Incorrect (missing directive):**

```tsx
// app/search/page.tsx
import { useQueryState } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q')
  // Error: Hooks can only be called inside Client Components

  return <input value={query ?? ''} onChange={e => setQuery(e.target.value)} />
}
```

**Correct (client component):**

```tsx
// app/search/page.tsx
'use client'

import { useQueryState } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q')

  return <input value={query ?? ''} onChange={e => setQuery(e.target.value)} />
}
```

**Alternative (extract to client component):**

```tsx
// app/search/page.tsx (Server Component)
import SearchInput from './SearchInput'

export default function SearchPage() {
  return (
    <div>
      <h1>Search</h1>
      <SearchInput />
    </div>
  )
}

// app/search/SearchInput.tsx (Client Component)
'use client'

import { useQueryState } from 'nuqs'

export default function SearchInput() {
  const [query, setQuery] = useQueryState('q')
  return <input value={query ?? ''} onChange={e => setQuery(e.target.value)} />
}
```

**Note:** For reading search params in Server Components without hooks, use `createSearchParamsCache` from `nuqs/server`.

Reference: [nuqs Server-Side](https://nuqs.dev/docs/server-side)

### 2.2 Define Shared Parsers in Dedicated File

**Impact: HIGH (prevents parser mismatch bugs between components)**

When multiple components use the same URL parameters, define parsers in a shared file. This prevents mismatches where one component uses `parseAsInteger` and another uses `parseAsString` for the same parameter.

**Incorrect (duplicate parser definitions):**

```tsx
// components/Pagination.tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  return <button onClick={() => setPage(p => p + 1)}>Next</button>
}

// components/PageInfo.tsx
'use client'
import { useQueryState } from 'nuqs'

export function PageInfo() {
  const [page] = useQueryState('page') // String parser - mismatch!
  return <span>Page: {page}</span> // Shows "1" not 1
}
```

**Correct (shared parsers):**

```tsx
// lib/searchParams.ts
import { parseAsInteger, parseAsString, parseAsStringLiteral } from 'nuqs'

export const searchParams = {
  page: parseAsInteger.withDefault(1),
  query: parseAsString.withDefault(''),
  sort: parseAsStringLiteral(['asc', 'desc'] as const).withDefault('asc')
}

// components/Pagination.tsx
'use client'
import { useQueryState } from 'nuqs'
import { searchParams } from '@/lib/searchParams'

export function Pagination() {
  const [page, setPage] = useQueryState('page', searchParams.page)
  return <button onClick={() => setPage(p => p + 1)}>Next</button>
}

// components/PageInfo.tsx
'use client'
import { useQueryState } from 'nuqs'
import { searchParams } from '@/lib/searchParams'

export function PageInfo() {
  const [page] = useQueryState('page', searchParams.page)
  return <span>Page: {page}</span> // Correctly typed as number
}
```

**Benefits:**
- Single source of truth for parser configuration
- TypeScript catches mismatches at compile time
- Easy to update defaults in one place
- Shared between client and server (with proper imports)

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 2.3 Ensure Compatible Next.js Version

**Impact: CRITICAL (prevents cryptic runtime errors from version mismatch)**

nuqs requires specific Next.js versions depending on the router you use. Using incompatible versions causes runtime errors or missing functionality.

**Version Requirements:**

| Router | Minimum Next.js | Notes |
|--------|-----------------|-------|
| App Router | 14.2.0+ | Full support including streaming |
| App Router (basic) | 14.0.0+ | Limited features |
| Pages Router | 12.0.0+ | Full support |

**Check your version:**

```bash
npm list next
# or
yarn why next
# or
pnpm why next
```

**Incorrect (outdated Next.js):**

```json
{
  "dependencies": {
    "next": "13.5.0",
    "nuqs": "^2.0.0"
  }
}
// May cause: "Cannot read property 'push' of undefined"
// Or: URL updates not reflected
```

**Correct (compatible version):**

```json
{
  "dependencies": {
    "next": "14.2.0",
    "nuqs": "^2.0.0"
  }
}
```

**Upgrade command:**

```bash
npm install next@latest
# or
yarn add next@latest
# or
pnpm add next@latest
```

**Common symptoms of version mismatch:**
- `useQueryState` returns undefined
- URL doesn't update on state change
- Hydration mismatches
- `TypeError: Cannot read property 'push' of undefined`

Reference: [nuqs Requirements](https://nuqs.dev/docs/getting-started)

### 2.4 Import Server Utilities from nuqs/server

**Impact: CRITICAL (prevents RSC-to-client boundary contamination errors)**

Server-side utilities like `createSearchParamsCache` must be imported from `nuqs/server`, not `nuqs`. The main `nuqs` export includes the `'use client'` directive which contaminates Server Components.

**Incorrect (wrong import):**

```tsx
// lib/searchParams.ts
import { createSearchParamsCache, parseAsString } from 'nuqs'
// Error: This import adds 'use client' to your server code

export const searchParamsCache = createSearchParamsCache({
  q: parseAsString.withDefault('')
})
```

**Correct (server import):**

```tsx
// lib/searchParams.ts
import {
  createSearchParamsCache,
  parseAsString,
  parseAsInteger
} from 'nuqs/server'
// No 'use client' directive - safe for Server Components

export const searchParamsCache = createSearchParamsCache({
  q: parseAsString.withDefault(''),
  page: parseAsInteger.withDefault(1)
})
```

**Usage in Server Component:**

```tsx
// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'
import type { SearchParams } from 'nuqs/server'

type PageProps = {
  searchParams: Promise<SearchParams>
}

export default async function SearchPage({ searchParams }: PageProps) {
  const { q, page } = await searchParamsCache.parse(searchParams)

  return (
    <div>
      <h1>Results for: {q}</h1>
      <p>Page: {page}</p>
    </div>
  )
}
```

**What to import from where:**

| Import | Source | Use In |
|--------|--------|--------|
| `useQueryState`, `useQueryStates` | `nuqs` | Client Components |
| `createSearchParamsCache` | `nuqs/server` | Server Components |
| Parsers (`parseAsString`, etc.) | `nuqs/server` for server, `nuqs` for client | Either |

Reference: [nuqs Server-Side](https://nuqs.dev/docs/server-side)

### 2.5 Wrap App with NuqsAdapter

**Impact: CRITICAL (prevents 100% of hook failures from missing provider)**

nuqs requires the `NuqsAdapter` provider to function. Without it, `useQueryState` hooks won't sync with the URL and may throw errors.

**Incorrect (missing adapter):**

```tsx
// src/app/layout.tsx
export default function RootLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>{children}</body>
    </html>
  )
}
// useQueryState calls will fail silently or throw
```

**Correct (App Router):**

```tsx
// src/app/layout.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default function RootLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  )
}
```

**Correct (Pages Router):**

```tsx
// src/pages/_app.tsx
import type { AppProps } from 'next/app'
import { NuqsAdapter } from 'nuqs/adapters/next/pages'

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <NuqsAdapter>
      <Component {...pageProps} />
    </NuqsAdapter>
  )
}
```

**Available adapters:**
- `nuqs/adapters/next/app` - Next.js App Router
- `nuqs/adapters/next/pages` - Next.js Pages Router
- `nuqs/adapters/react` - Plain React (with react-router)
- `nuqs/adapters/remix` - Remix
- `nuqs/adapters/react-router/v6` - React Router v6
- `nuqs/adapters/react-router/v7` - React Router v7

Reference: [nuqs Adapters](https://nuqs.dev/docs/adapters)

---

## 3. State Management

**Impact: HIGH**

Proper use of useQueryState vs useQueryStates, default values, and null handling prevents unnecessary complexity and bugs.

### 3.1 Avoid Derived State from URL Parameters

**Impact: HIGH (prevents sync bugs and unnecessary re-renders)**

Don't copy URL state into local `useState`. This creates two sources of truth that can drift out of sync. Use the URL state directly or compute derived values.

**Incorrect (duplicated state):**

```tsx
'use client'
import { useState, useEffect } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [urlPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [page, setPage] = useState(urlPage) // Duplicated!

  useEffect(() => {
    setPage(urlPage) // Sync attempt - can cause loops
  }, [urlPage])

  return <span>Page: {page}</span>
}
```

**Correct (single source of truth):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))

  return <span>Page: {page}</span>
}
```

**For derived values, use useMemo:**

```tsx
'use client'
import { useMemo } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page] = useQueryState('page', parseAsInteger.withDefault(1))

  // Derived value, not duplicated state
  const isFirstPage = useMemo(() => page === 1, [page])
  const pageRange = useMemo(
    () => ({ start: (page - 1) * 10, end: page * 10 }),
    [page]
  )

  return (
    <div>
      <span>Page: {page}</span>
      {isFirstPage && <span>(First page)</span>}
    </div>
  )
}
```

**Exception: Debounced input**

```tsx
// OK to have local state for debounced input
const [query, setQuery] = useQueryState('q')
const [inputValue, setInputValue] = useState(query ?? '')

// Debounce URL updates
useEffect(() => {
  const timeout = setTimeout(() => setQuery(inputValue || null), 300)
  return () => clearTimeout(timeout)
}, [inputValue, setQuery])
```

Reference: [React Derived State](https://react.dev/learn/you-might-not-need-an-effect#updating-state-based-on-props-or-state)

### 3.2 Clear URL Parameters with null

**Impact: HIGH (reduces URL clutter by removing unnecessary parameters)**

To remove a parameter from the URL, set it to `null`. Setting to empty string (`''`) or `0` keeps the parameter in the URL with that value.

**Incorrect (empty string in URL):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')

  const clear = () => setQuery('')
  // URL: ?q=  (empty but parameter remains)

  return (
    <div>
      <input value={query ?? ''} onChange={e => setQuery(e.target.value)} />
      <button onClick={clear}>Clear</button>
    </div>
  )
}
```

**Correct (null removes parameter):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')

  const clear = () => setQuery(null)
  // URL: / (parameter removed entirely)

  return (
    <div>
      <input
        value={query ?? ''}
        onChange={e => setQuery(e.target.value || null)}
      />
      <button onClick={clear}>Clear</button>
    </div>
  )
}
```

**Pattern: Convert empty to null on change:**

```tsx
<input
  value={query ?? ''}
  onChange={e => setQuery(e.target.value || null)}
/>
// Empty input → null → clean URL
// "search term" → "search term" → ?q=search+term
```

**With typed parsers:**

```tsx
const [count, setCount] = useQueryState('count', parseAsInteger)

// Clear the parameter
setCount(null) // URL: /

// With default, null resets to default behavior
const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
setPage(null) // URL: / (page defaults to 1, not shown)
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 3.3 Handle Controlled Input Value Properly

**Impact: HIGH (prevents uncontrolled to controlled warnings)**

React requires controlled inputs to always have a defined `value`. Since nuqs returns `null` when a parameter is absent, you must provide a fallback for input elements.

**Incorrect (uncontrolled warning):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')
  // query is string | null

  return (
    <input
      value={query} // Warning: value is null initially
      onChange={e => setQuery(e.target.value)}
    />
  )
}
// Warning: A component is changing an uncontrolled input to be controlled
```

**Correct (fallback value):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q')

  return (
    <input
      value={query ?? ''} // Fallback to empty string
      onChange={e => setQuery(e.target.value || null)}
    />
  )
}
```

**Alternative (withDefault):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // query is string (never null)

  return (
    <input
      value={query} // No fallback needed
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**For select elements:**

```tsx
const [sort, setSort] = useQueryState(
  'sort',
  parseAsStringLiteral(['asc', 'desc'] as const).withDefault('asc')
)

<select value={sort} onChange={e => setSort(e.target.value as typeof sort)}>
  <option value="asc">Ascending</option>
  <option value="desc">Descending</option>
</select>
```

Reference: [React Controlled Components](https://react.dev/reference/react-dom/components/input#controlling-an-input-with-a-state-variable)

### 3.4 Use Functional Updates for State Derived from Previous Value

**Impact: HIGH (prevents stale closure bugs and race conditions)**

When the new state depends on the previous state (incrementing, toggling, appending), use functional updates. Direct state references in closures can be stale.

**Incorrect (stale closure):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger.withDefault(0))

  const incrementTwice = () => {
    setCount(count + 1) // Uses stale `count`
    setCount(count + 1) // Still uses same stale `count`
    // Result: increments by 1, not 2
  }

  return <button onClick={incrementTwice}>+2</button>
}
```

**Correct (functional update):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger.withDefault(0))

  const incrementTwice = () => {
    setCount(c => c + 1) // Gets latest value
    setCount(c => c + 1) // Gets updated value
    // Result: correctly increments by 2
  }

  return <button onClick={incrementTwice}>+2</button>
}
```

**More examples:**

```tsx
// Toggle boolean
const [enabled, setEnabled] = useQueryState('enabled', parseAsBoolean.withDefault(false))
setEnabled(e => !e)

// Append to array
const [tags, setTags] = useQueryState(
  'tags',
  parseAsArrayOf(parseAsString).withDefault([])
)
setTags(t => [...t, 'new-tag'])

// Remove from array
setTags(t => t.filter(tag => tag !== 'remove-me'))
```

Reference: [nuqs State Updates](https://nuqs.dev/docs)

### 3.5 Use Setter Return Value for URL Access

**Impact: MEDIUM (enables accurate URL tracking for analytics/sharing)**

The state setter returns a Promise that resolves to the new URL search string. Use this for analytics, logging, or when you need the resulting URL immediately.

**Incorrect (manually constructing URL):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function ShareButton() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  const share = () => {
    setQuery('shared-term')
    // Manual URL construction - may not match nuqs output
    const url = `${window.location.pathname}?q=shared-term`
    navigator.clipboard.writeText(url)
  }

  return <button onClick={share}>Share</button>
}
```

**Correct (use return value):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function ShareButton() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  const share = async () => {
    const searchString = await setQuery('shared-term')
    // searchString is "q=shared-term" or similar
    const url = `${window.location.origin}${window.location.pathname}?${searchString}`
    await navigator.clipboard.writeText(url)
  }

  return <button onClick={share}>Share</button>
}
```

**For analytics:**

```tsx
const trackSearch = async (term: string) => {
  const searchString = await setQuery(term)
  analytics.track('search', {
    term,
    url: `?${searchString}`
  })
}
```

**With useQueryStates:**

```tsx
const [coords, setCoords] = useQueryStates({
  lat: parseAsFloat,
  lng: parseAsFloat
})

const shareLocation = async () => {
  const searchString = await setCoords({ lat: 48.8566, lng: 2.3522 })
  // searchString: "lat=48.8566&lng=2.3522"
}
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 3.6 Use useQueryStates for Related Parameters

**Impact: HIGH (atomic updates prevent intermediate invalid states)**

When multiple URL parameters are logically related (like coordinates, date ranges, or filters), use `useQueryStates` for atomic updates. Multiple `useQueryState` calls update the URL independently, causing intermediate states.

**Incorrect (separate hooks, non-atomic):**

```tsx
'use client'
import { useQueryState, parseAsFloat } from 'nuqs'

export default function MapView() {
  const [lat, setLat] = useQueryState('lat', parseAsFloat.withDefault(0))
  const [lng, setLng] = useQueryState('lng', parseAsFloat.withDefault(0))
  const [zoom, setZoom] = useQueryState('zoom', parseAsFloat.withDefault(10))

  const goToParis = () => {
    setLat(48.8566)   // URL update 1
    setLng(2.3522)    // URL update 2
    setZoom(12)       // URL update 3
    // Three separate URL updates, three history entries if using push
  }

  return <button onClick={goToParis}>Go to Paris</button>
}
```

**Correct (single hook, atomic):**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates({
    lat: parseAsFloat.withDefault(0),
    lng: parseAsFloat.withDefault(0),
    zoom: parseAsInteger.withDefault(10)
  })

  const goToParis = () => {
    setCoords({
      lat: 48.8566,
      lng: 2.3522,
      zoom: 12
    })
    // Single atomic URL update
  }

  return (
    <div>
      <p>Location: {coords.lat}, {coords.lng} (zoom: {coords.zoom})</p>
      <button onClick={goToParis}>Go to Paris</button>
    </div>
  )
}
```

**Partial updates also work:**

```tsx
// Only update zoom, keep lat/lng
setCoords({ zoom: 15 })

// Update lat/lng, keep zoom
setCoords({ lat: 51.5074, lng: -0.1278 })
```

Reference: [nuqs useQueryStates](https://nuqs.dev/docs/usequerystates)

### 3.7 Use withOptions for Parser-Level Configuration

**Impact: MEDIUM (reduces boilerplate and ensures consistent behavior)**

Instead of passing options to every `useQueryState` call, configure options on the parser itself with `withOptions`. This ensures consistent behavior and reduces repetition.

**Incorrect (repeated options):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', {
    ...parseAsString,
    shallow: false,
    throttleMs: 500,
    history: 'push'
  })

  const [filter, setFilter] = useQueryState('filter', {
    ...parseAsString,
    shallow: false,
    throttleMs: 500,
    history: 'push'
  })

  // Repeated configuration for each parameter
}
```

**Correct (parser-level options):**

```tsx
// lib/searchParams.ts
import { parseAsString, parseAsInteger } from 'nuqs'

const serverSyncOptions = {
  shallow: false,
  throttleMs: 500,
  history: 'push' as const
}

export const searchParams = {
  query: parseAsString.withDefault('').withOptions(serverSyncOptions),
  filter: parseAsString.withDefault('').withOptions(serverSyncOptions),
  page: parseAsInteger.withDefault(1).withOptions(serverSyncOptions)
}

// components/SearchPage.tsx
'use client'
import { useQueryState } from 'nuqs'
import { searchParams } from '@/lib/searchParams'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', searchParams.query)
  const [filter, setFilter] = useQueryState('filter', searchParams.filter)
  const [page, setPage] = useQueryState('page', searchParams.page)

  // All use the same options consistently
}
```

**Options can be chained:**

```tsx
parseAsInteger
  .withDefault(1)
  .withOptions({ shallow: false })
  .withOptions({ throttleMs: 300 }) // Merges with previous options
```

Reference: [nuqs Options](https://nuqs.dev/docs/options)

---

## 4. Server Integration

**Impact: HIGH**

Server cache and shallow routing configuration determines whether state changes trigger expensive server re-renders.

### 4.1 Call parse() Before get() in Server Components

**Impact: HIGH (prevents undefined values and runtime errors)**

`createSearchParamsCache` requires calling `parse()` at the page level before calling `get()` in nested components. Forgetting `parse()` causes `get()` to return undefined or throw.

**Incorrect (missing parse):**

```tsx
// app/search/page.tsx
import { ResultsHeader } from './ResultsHeader'

export default async function SearchPage({ searchParams }) {
  // Missing: await searchParamsCache.parse(searchParams)

  return (
    <div>
      <ResultsHeader /> {/* Will fail or return undefined */}
      <Results />
    </div>
  )
}

// components/ResultsHeader.tsx
import { searchParamsCache } from '@/lib/searchParams'

export function ResultsHeader() {
  const query = searchParamsCache.get('q') // Error: cache not initialized
  return <h1>Results for {query}</h1>
}
```

**Correct (parse at page level):**

```tsx
// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'
import { ResultsHeader } from './ResultsHeader'
import type { SearchParams } from 'nuqs/server'

type PageProps = {
  searchParams: Promise<SearchParams>
}

export default async function SearchPage({ searchParams }: PageProps) {
  // Parse FIRST, before rendering any children
  await searchParamsCache.parse(searchParams)

  return (
    <div>
      <ResultsHeader /> {/* Now get() works */}
      <Results />
    </div>
  )
}

// components/ResultsHeader.tsx
import { searchParamsCache } from '@/lib/searchParams'

export function ResultsHeader() {
  const query = searchParamsCache.get('q') // Works correctly
  return <h1>Results for {query}</h1>
}
```

**Parse and destructure in one step:**

```tsx
export default async function SearchPage({ searchParams }: PageProps) {
  const { q, page } = await searchParamsCache.parse(searchParams)
  // Use q and page directly, or let children use get()

  return <Results query={q} page={page} />
}
```

Reference: [nuqs Server Cache](https://nuqs.dev/docs/server-side)

### 4.2 Handle Async searchParams in Next.js 15+

**Impact: HIGH (prevents build errors in Next.js 15 with async props)**

In Next.js 15+, `searchParams` is a Promise that must be awaited. Using it directly without await causes TypeScript errors and runtime issues.

**Incorrect (Next.js 15+ without await):**

```tsx
// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'

type PageProps = {
  searchParams: { q?: string } // Wrong type for Next.js 15+
}

export default async function SearchPage({ searchParams }: PageProps) {
  // searchParams is a Promise, not an object
  const { q } = searchParamsCache.parse(searchParams) // Type error
}
```

**Correct (Next.js 15+):**

```tsx
// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'
import type { SearchParams } from 'nuqs/server'

type PageProps = {
  searchParams: Promise<SearchParams> // Correct type
}

export default async function SearchPage({ searchParams }: PageProps) {
  // Await the Promise
  const { q, page } = await searchParamsCache.parse(searchParams)

  return <Results query={q} page={page} />
}
```

**For Next.js 14 and earlier:**

```tsx
// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'

type PageProps = {
  searchParams: Record<string, string | string[] | undefined>
}

export default function SearchPage({ searchParams }: PageProps) {
  // No await needed in Next.js 14
  const { q, page } = searchParamsCache.parse(searchParams)

  return <Results query={q} page={page} />
}
```

**Version-agnostic pattern:**

```tsx
import type { SearchParams } from 'nuqs/server'

type PageProps = {
  searchParams: Promise<SearchParams>
}

export default async function SearchPage({ searchParams }: PageProps) {
  // Works in both Next.js 14 and 15
  const { q } = await searchParamsCache.parse(searchParams)
}
```

Reference: [Next.js 15 Migration](https://nextjs.org/docs/app/building-your-application/upgrading/version-15)

### 4.3 Integrate useTransition for Loading States

**Impact: HIGH (100% visibility into server fetch pending state)**

When using `shallow: false`, integrate React's `useTransition` to track when the server is fetching new data. This enables loading indicators during URL-triggered server updates.

**Incorrect (no loading feedback):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false
  }))
  // User types, waits with no feedback while server fetches

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
      placeholder="Search..."
    />
  )
}
```

**Correct (loading state):**

```tsx
'use client'
import { useTransition } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [isLoading, startTransition] = useTransition()
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false,
    startTransition
  }))

  return (
    <div>
      <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="Search..."
      />
      {isLoading && <span className="spinner" />}
    </div>
  )
}
```

**With disabled interaction during load:**

```tsx
'use client'
import { useTransition } from 'react'
import { useQueryStates, parseAsString, parseAsInteger } from 'nuqs'

export default function FilterPanel() {
  const [isLoading, startTransition] = useTransition()
  const [filters, setFilters] = useQueryStates(
    {
      category: parseAsString.withDefault(''),
      page: parseAsInteger.withDefault(1)
    },
    {
      shallow: false,
      startTransition
    }
  )

  return (
    <fieldset disabled={isLoading}>
      <select
        value={filters.category}
        onChange={e => setFilters({ category: e.target.value, page: 1 })}
      >
        <option value="">All</option>
        <option value="electronics">Electronics</option>
      </select>
      {isLoading && <p>Updating results...</p>}
    </fieldset>
  )
}
```

Reference: [nuqs useTransition Integration](https://nuqs.dev/docs/options)

### 4.4 Share Parsers Between Client and Server

**Impact: HIGH (prevents client/server hydration mismatches)**

Define parsers once and reuse them in both `createSearchParamsCache` (server) and `useQueryState` (client). This ensures consistent parsing behavior and prevents bugs from mismatched configurations.

**Incorrect (separate definitions):**

```tsx
// app/search/page.tsx (Server)
import { createSearchParamsCache, parseAsInteger } from 'nuqs/server'

const cache = createSearchParamsCache({
  page: parseAsInteger.withDefault(1)
})

// components/Pagination.tsx (Client)
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export function Pagination() {
  // Different default - inconsistent!
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(0))
}
```

**Correct (shared definition):**

```tsx
// lib/searchParams.ts
import { parseAsInteger, parseAsString } from 'nuqs' // Works for both

export const searchParamsParsers = {
  q: parseAsString.withDefault(''),
  page: parseAsInteger.withDefault(1),
  limit: parseAsInteger.withDefault(10)
}

// lib/searchParams.server.ts
import { createSearchParamsCache } from 'nuqs/server'
import { searchParamsParsers } from './searchParams'

export const searchParamsCache = createSearchParamsCache(searchParamsParsers)

// app/search/page.tsx (Server)
import { searchParamsCache } from '@/lib/searchParams.server'

export default async function SearchPage({ searchParams }) {
  const { q, page } = await searchParamsCache.parse(searchParams)
  return <Results query={q} page={page} />
}

// components/Pagination.tsx (Client)
'use client'
import { useQueryState } from 'nuqs'
import { searchParamsParsers } from '@/lib/searchParams'

export function Pagination() {
  const [page, setPage] = useQueryState('page', searchParamsParsers.page)
  // Uses same parser with same default as server
}
```

**Benefits:**
- Single source of truth for defaults
- TypeScript catches inconsistencies
- Easier to update configuration

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 4.5 Use createSearchParamsCache for Server Components

**Impact: HIGH (eliminates prop drilling across N component levels)**

In Server Components, use `createSearchParamsCache` to access URL parameters with type safety. This avoids prop drilling and provides the same parsers as client-side hooks.

**Incorrect (manual parsing):**

```tsx
// app/search/page.tsx
type PageProps = {
  searchParams: Promise<{ q?: string; page?: string }>
}

export default async function SearchPage({ searchParams }: PageProps) {
  const params = await searchParams
  const query = params.q ?? ''
  const page = parseInt(params.page ?? '1', 10) // Manual parsing
  // No type safety, parsing logic duplicated

  return <Results query={query} page={page} />
}
```

**Correct (search params cache):**

```tsx
// lib/searchParams.ts
import {
  createSearchParamsCache,
  parseAsString,
  parseAsInteger
} from 'nuqs/server'

export const searchParamsCache = createSearchParamsCache({
  q: parseAsString.withDefault(''),
  page: parseAsInteger.withDefault(1)
})

// app/search/page.tsx
import { searchParamsCache } from '@/lib/searchParams'
import type { SearchParams } from 'nuqs/server'

type PageProps = {
  searchParams: Promise<SearchParams>
}

export default async function SearchPage({ searchParams }: PageProps) {
  // Parse once at page level
  const { q, page } = await searchParamsCache.parse(searchParams)

  return <Results query={q} page={page} />
}
```

**Access in nested Server Components:**

```tsx
// components/ResultsHeader.tsx
import { searchParamsCache } from '@/lib/searchParams'

export function ResultsHeader() {
  // No props needed - access from cache
  const query = searchParamsCache.get('q')
  const page = searchParamsCache.get('page')

  return <h1>Results for "{query}" (Page {page})</h1>
}
```

**Important:** Call `parse()` once at the page level before using `get()` in nested components.

Reference: [nuqs Server-Side](https://nuqs.dev/docs/server-side)

### 4.6 Use shallow:false to Trigger Server Re-renders

**Impact: HIGH (enables server-side data refetching on URL change)**

By default, nuqs updates are client-side only (`shallow: true`). Set `shallow: false` to trigger Server Component re-renders when URL changes, enabling server-side data fetching.

**Incorrect (server data never refreshes):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // shallow: true (default) - server doesn't see URL changes
  // Server-fetched data stays stale

  return <button onClick={() => setPage(p => p + 1)}>Next</button>
}
```

**Correct (server refetches on change):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    shallow: false // Notify server of URL changes
  }))
  // Server Components re-render with new page value

  return <button onClick={() => setPage(p => p + 1)}>Next</button>
}
```

**With loading state using useTransition:**

```tsx
'use client'
import { useTransition } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [isLoading, startTransition] = useTransition()
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    shallow: false,
    startTransition // Shows loading during server fetch
  }))

  return (
    <div>
      {isLoading && <span>Loading...</span>}
      <button onClick={() => setPage(p => p + 1)} disabled={isLoading}>
        Next
      </button>
    </div>
  )
}
```

**When to use shallow:false:**
- Pagination with server-fetched data
- Search that triggers server queries
- Filters that affect server-rendered content
- Any state that affects Server Component output

Reference: [nuqs Shallow Option](https://nuqs.dev/docs/options)

---

## 5. Performance Optimization

**Impact: MEDIUM**

Throttling, batching, and update coalescing prevent browser rate-limiting and reduce unnecessary URL updates.

### 5.1 Debounce Search Input Before URL Update

**Impact: MEDIUM (reduces server requests during typing)**

For search inputs with `shallow: false`, debounce the URL update to avoid hammering the server with requests on every keystroke. Keep local state for instant UI feedback.

**Incorrect (server request per keystroke):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false // Every keystroke triggers server fetch
  }))

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Correct (debounced URL update):**

```tsx
'use client'
import { useState, useEffect, useTransition } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [isLoading, startTransition] = useTransition()
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    shallow: false,
    startTransition
  }))

  // Local state for instant UI
  const [inputValue, setInputValue] = useState(query)

  // Sync URL → input when URL changes externally
  useEffect(() => {
    setInputValue(query)
  }, [query])

  // Debounce input → URL
  useEffect(() => {
    const timeout = setTimeout(() => {
      if (inputValue !== query) {
        setQuery(inputValue || null)
      }
    }, 300)
    return () => clearTimeout(timeout)
  }, [inputValue, query, setQuery])

  return (
    <div>
      <input
        value={inputValue}
        onChange={e => setInputValue(e.target.value)}
        placeholder="Search..."
      />
      {isLoading && <span>Searching...</span>}
    </div>
  )
}
```

**Alternative (useDeferredValue):**

```tsx
'use client'
import { useDeferredValue } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  const deferredQuery = useDeferredValue(query)
  const isStale = query !== deferredQuery

  return (
    <div style={{ opacity: isStale ? 0.7 : 1 }}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <Results query={deferredQuery} />
    </div>
  )
}
```

Reference: [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)

### 5.2 Memoize Components Using URL State

**Impact: MEDIUM (prevents unnecessary re-renders on URL changes)**

When URL state changes, all components using that state re-render. Use `React.memo` and extract URL-dependent logic to prevent cascading re-renders.

**Incorrect (entire page re-renders):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <div>
      <SearchInput query={query} setQuery={setQuery} />
      <ExpensiveSidebar /> {/* Re-renders on every query change */}
      <ResultsList query={query} />
    </div>
  )
}

function ExpensiveSidebar() {
  // Heavy computation that doesn't need query
  return <aside>...</aside>
}
```

**Correct (memoized components):**

```tsx
'use client'
import { memo } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchPage() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <div>
      <SearchInput query={query} setQuery={setQuery} />
      <ExpensiveSidebar /> {/* Memoized - doesn't re-render */}
      <ResultsList query={query} />
    </div>
  )
}

const ExpensiveSidebar = memo(function ExpensiveSidebar() {
  return <aside>...</aside>
})
```

**Alternative (extract hook usage):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

// Only this component re-renders on query change
function SearchSection() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))

  return (
    <>
      <SearchInput query={query} setQuery={setQuery} />
      <ResultsList query={query} />
    </>
  )
}

export default function SearchPage() {
  return (
    <div>
      <SearchSection />
      <ExpensiveSidebar /> {/* Not affected by query changes */}
    </div>
  )
}
```

Reference: [React memo](https://react.dev/reference/react/memo)

### 5.3 Throttle Rapid URL Updates

**Impact: MEDIUM (prevents browser history API rate limiting)**

Browsers rate-limit History API calls. Rapid updates (typing, sliders, dragging) can exceed this limit, causing dropped updates. Use `throttleMs` to batch updates.

**Incorrect (every keystroke updates URL):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // Every keystroke pushes to history
  // Browser may throttle after ~100 rapid updates

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Correct (throttled updates):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    throttleMs: 300 // Batch updates every 300ms
  }))
  // UI updates instantly, URL updates at most every 300ms

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**For sliders and drag operations:**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function VolumeSlider() {
  const [volume, setVolume] = useQueryState('volume', parseAsInteger.withDefault(50).withOptions({
    throttleMs: 100 // More responsive for continuous input
  }))

  return (
    <input
      type="range"
      min={0}
      max={100}
      value={volume}
      onChange={e => setVolume(Number(e.target.value))}
    />
  )
}
```

**Override per-update:**

```tsx
// Normal updates use default throttle
setQuery('new value')

// Force immediate update (e.g., on blur)
setQuery('final value', { throttleMs: 0 })
```

**Note:** Minimum throttle is 50ms. UI state updates instantly regardless of throttle.

Reference: [nuqs Throttling](https://nuqs.dev/docs/options)

### 5.4 Use clearOnDefault for Clean URLs

**Impact: MEDIUM (reduces URL length by 20-50% for default values)**

By default, nuqs removes parameters from the URL when they match the default value. This keeps URLs clean. Set `clearOnDefault: false` only when you need the parameter always visible.

**Incorrect (default always shown in URL):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    clearOnDefault: false // Unnecessary!
  }))
  // URL always shows ?page=1 even on first page
  // Clutters shareable URLs, hurts SEO

  return <button onClick={() => setPage(1)}>First</button>
}
```

**Correct (clean URLs by default):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // clearOnDefault: true (default)
  // page=1: URL is /search (clean)
  // page=2: URL is /search?page=2

  return (
    <div>
      <button onClick={() => setPage(1)}>First</button>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </div>
  )
}
```

**When clearOnDefault: false is appropriate:**
- Analytics tracking requires all parameters
- API expects explicit parameter even for default
- Debugging where you need to see all state

Reference: [nuqs clearOnDefault](https://nuqs.dev/docs/options)

### 5.5 Use createSerializer for Link URLs

**Impact: MEDIUM (enables SSR-compatible URL generation without hooks)**

When generating URLs for links or navigation without needing state, use `createSerializer`. This avoids unnecessary hook usage and works in Server Components.

**Incorrect (hook for URL generation only):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function PaginationLinks({ totalPages }: { totalPages: number }) {
  const [page] = useQueryState('page', parseAsInteger.withDefault(1))

  // Using state just to generate URLs
  return (
    <nav>
      {Array.from({ length: totalPages }, (_, i) => (
        <a key={i} href={`?page=${i + 1}`}>
          {i + 1}
        </a>
      ))}
    </nav>
  )
}
```

**Correct (serializer utility):**

```tsx
// lib/searchParams.ts
import { createSerializer, parseAsInteger, parseAsString } from 'nuqs/server'

export const searchParams = {
  q: parseAsString,
  page: parseAsInteger.withDefault(1)
}

export const serialize = createSerializer(searchParams)

// components/PaginationLinks.tsx (can be Server Component)
import { serialize } from '@/lib/searchParams'

export default function PaginationLinks({ totalPages }: { totalPages: number }) {
  return (
    <nav>
      {Array.from({ length: totalPages }, (_, i) => (
        <a key={i} href={`?${serialize({ page: i + 1 })}`}>
          {i + 1}
        </a>
      ))}
    </nav>
  )
}
```

**Building on existing URL:**

```tsx
import { serialize } from '@/lib/searchParams'

// Preserve existing params, change page
const currentParams = { q: 'react', page: 1 }
const nextPageUrl = `?${serialize({ ...currentParams, page: 2 })}`
// Result: ?q=react&page=2
```

**With base URL:**

```tsx
const url = serialize('/search', { q: 'react', page: 1 })
// Result: /search?q=react&page=1
```

Reference: [nuqs createSerializer](https://nuqs.dev/docs/utilities)

---

## 6. History & Navigation

**Impact: MEDIUM**

History mode selection affects UX - push vs replace impacts back button behavior and navigation experience.

### 6.1 Control Scroll Behavior on URL Changes

**Impact: MEDIUM (prevents jarring scroll jumps on state changes)**

By default, nuqs doesn't scroll on URL changes. Use the `scroll` option to control whether state changes scroll to the top of the page.

**Incorrect (unwanted scroll on filter change):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function FilterPanel() {
  const [filter, setFilter] = useQueryState('filter', parseAsString.withDefault('').withOptions({
    scroll: true // Bad for filters - user loses their place!
  }))

  return (
    <select value={filter} onChange={e => setFilter(e.target.value)}>
      <option value="">All</option>
      <option value="active">Active</option>
    </select>
  )
}
```

**Correct (no scroll for filters, scroll for pagination):**

```tsx
'use client'
import { useQueryState, parseAsString, parseAsInteger } from 'nuqs'

export default function SearchPage() {
  // No scroll for filters - user stays in place
  const [filter, setFilter] = useQueryState('filter', parseAsString.withDefault(''))

  // Scroll for pagination - user sees new content from top
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    scroll: true,
    history: 'push'
  }))

  return (
    <div>
      <select value={filter} onChange={e => setFilter(e.target.value)}>
        <option value="">All</option>
        <option value="active">Active</option>
      </select>
      <button onClick={() => setPage(p => p + 1)}>Next Page</button>
    </div>
  )
}
```

Reference: [nuqs Scroll Option](https://nuqs.dev/docs/options)

### 6.2 Handle Browser Back/Forward Navigation

**Impact: MEDIUM (prevents stale UI after browser navigation)**

nuqs automatically syncs state with URL when users navigate with browser back/forward buttons. Ensure your UI handles these state changes correctly.

**Incorrect (local state gets out of sync):**

```tsx
'use client'
import { useState, useEffect } from 'react'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [urlPage] = useQueryState('page', parseAsInteger.withDefault(1))
  const [localPage, setLocalPage] = useState(urlPage)
  // User navigates back - urlPage updates but localPage doesn't!

  return <p>Page {localPage}</p> // Shows stale value
}
```

**Correct (use URL state directly):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push'
  }))
  // User: page 1 → 2 → 3
  // Back button: page becomes 2 (automatic)
  // UI re-renders with new page value

  return (
    <div>
      <p>Page {page}</p>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </div>
  )
}
```

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 6.3 Use history:push for Navigation-Like State

**Impact: MEDIUM (enables back button for state navigation)**

Use `history: 'push'` when state changes represent navigation that users would expect to undo with the back button (pagination, tabs, modal state).

**Incorrect (replace loses navigation history):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1))
  // history: 'replace' (default)
  // User clicks page 1 → 2 → 3 → back button → leaves site!

  return (
    <nav>
      <button onClick={() => setPage(p => p - 1)}>Previous</button>
      <span>Page {page}</span>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </nav>
  )
}
```

**Correct (push enables back navigation):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Pagination() {
  const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
    history: 'push'
  }))
  // User clicks page 1 → 2 → 3 → back button → page 2

  return (
    <nav>
      <button onClick={() => setPage(p => p - 1)}>Previous</button>
      <span>Page {page}</span>
      <button onClick={() => setPage(p => p + 1)}>Next</button>
    </nav>
  )
}
```

**Typical use cases for history:push:**
- Pagination
- Tab selection
- Modal open/close state
- Step-by-step wizards
- Filter panel expansion

**Mix modes when needed:**

```tsx
const [page, setPage] = useQueryState('page', parseAsInteger.withDefault(1).withOptions({
  history: 'push'
}))

// Programmatic navigation pushes
setPage(5)

// But "reset" replaces to avoid back-button spam
setPage(1, { history: 'replace' })
```

Reference: [nuqs History Option](https://nuqs.dev/docs/options)

### 6.4 Use history:replace for Ephemeral State

**Impact: MEDIUM (prevents history pollution from frequent updates)**

Use `history: 'replace'` (default) for state that changes frequently or represents intermediate values users wouldn't want to navigate through (typing, sliders, filters).

**Correct (replace for typing):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  // history: 'replace' (default)
  // Typing "react" doesn't create 5 history entries

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
      placeholder="Search..."
    />
  )
}
```

**Incorrect (push for typing):**

```tsx
'use client'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchBox() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault('').withOptions({
    history: 'push' // Don't do this!
  }))
  // Typing "react" creates entries: r, re, rea, reac, react
  // Back button is unusable

  return (
    <input
      value={query}
      onChange={e => setQuery(e.target.value)}
    />
  )
}
```

**Typical use cases for history:replace (default):**
- Search input text
- Slider/range values
- Real-time filter changes
- Sort order selection
- Any rapidly-changing state

**Hybrid pattern (replace during typing, push on submit):**

```tsx
'use client'
import { useState } from 'react'
import { useQueryState, parseAsString } from 'nuqs'

export default function SearchForm() {
  const [query, setQuery] = useQueryState('q', parseAsString.withDefault(''))
  const [input, setInput] = useState(query)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    setQuery(input, { history: 'push' }) // Push on explicit submit
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={input} onChange={e => setInput(e.target.value)} />
      <button type="submit">Search</button>
    </form>
  )
}
```

Reference: [nuqs History Option](https://nuqs.dev/docs/options)

---

## 7. Debugging & Testing

**Impact: LOW-MEDIUM**

Debug logging, testing strategies, and common error diagnosis enable faster development cycles.

### 7.1 Diagnose Common nuqs Errors

**Impact: LOW-MEDIUM (reduces debugging time from hours to minutes)**

Reference for diagnosing frequent nuqs issues and their solutions.

**Incorrect (missing adapter causes cryptic error):**

```tsx
// app/layout.tsx - Missing NuqsAdapter
export default function RootLayout({ children }) {
  return (
    <html>
      <body>{children}</body>
    </html>
  )
}
// Error: "Cannot read property 'push' of undefined"
```

**Correct (add NuqsAdapter):**

```tsx
// app/layout.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <NuqsAdapter>{children}</NuqsAdapter>
      </body>
    </html>
  )
}
```

**Other common errors and fixes:**

| Error | Cause | Fix |
|-------|-------|-----|
| "Hooks can only be called inside Client Components" | Missing 'use client' | Add `'use client'` directive |
| "Uncontrolled input" warning | Value is null | Use `value={query ?? ''}` |
| Hydration mismatch | Different defaults | Use shared parsers with withDefault |
| URL not updating | Missing adapter or old Next.js | Check adapter and version |
| State undefined in Server Component | Missing parse() | Call `parse()` before `get()` |

Reference: [nuqs Documentation](https://nuqs.dev/docs)

### 7.2 Enable Debug Logging for Troubleshooting

**Impact: LOW-MEDIUM (reduces debugging time by 5-10×)**

Enable nuqs debug logs to understand state changes, URL updates, and timing. Useful for diagnosing issues with state synchronization or unexpected behavior.

**Incorrect (no visibility into nuqs operations):**

```tsx
'use client'
import { useQueryState, parseAsInteger } from 'nuqs'

export default function Counter() {
  const [count, setCount] = useQueryState('count', parseAsInteger.withDefault(0))
  // Something's not working, but no way to see what nuqs is doing
  // Have to guess and add console.logs everywhere

  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

**Correct (enable debug logging):**

```javascript
// Run in browser DevTools console FIRST
localStorage.debug = 'nuqs'
// Then reload the page
// Now you see: [nuqs] useQueryState 'count' initialized with 0
// And: [nuqs] useQueryState 'count' updated to 1
```

**Disable when done:**

```javascript
// Run in browser DevTools console
delete localStorage.debug
```

**Performance timing markers:**

Debug mode also records User Timing markers visible in the Performance tab:
- `nuqs:parse` - Time to parse URL parameters
- `nuqs:serialize` - Time to serialize state to URL
- `nuqs:update` - Time for URL update

Reference: [nuqs Debugging](https://nuqs.dev/docs)

### 7.3 Test Components with URL State

**Impact: LOW-MEDIUM (enables reliable CI/CD testing of nuqs components)**

Test components that use nuqs by providing the NuqsTestingAdapter and controlling URL state in tests.

**Incorrect (test fails without adapter):**

```tsx
// components/Pagination.test.tsx
import { render, screen } from '@testing-library/react'
import Pagination from './Pagination'

it('displays current page', () => {
  render(<Pagination />) // Fails: no NuqsAdapter
  expect(screen.getByText('Page 1')).toBeInTheDocument()
})
```

**Correct (use NuqsTestingAdapter):**

```tsx
// test/utils.tsx
import { NuqsTestingAdapter } from 'nuqs/adapters/testing'
import { render, type RenderOptions } from '@testing-library/react'

export function renderWithNuqs(
  ui: React.ReactElement,
  { searchParams = {}, ...options }: RenderOptions & { searchParams?: Record<string, string> } = {}
) {
  return render(
    <NuqsTestingAdapter searchParams={searchParams}>
      {ui}
    </NuqsTestingAdapter>,
    options
  )
}

// components/Pagination.test.tsx
import { screen } from '@testing-library/react'
import { renderWithNuqs } from '@/test/utils'
import Pagination from './Pagination'

it('displays current page from URL', () => {
  renderWithNuqs(<Pagination />, { searchParams: { page: '5' } })
  expect(screen.getByText('Page 5')).toBeInTheDocument()
})
```

Reference: [nuqs Testing Adapter](https://nuqs.dev/docs/testing)

---

## 8. Advanced Patterns

**Impact: LOW**

Custom parsers, serializers, URL key mapping for complex use cases requiring careful implementation.

### 8.1 Create Custom Parsers for Complex Types

**Impact: LOW (prevents runtime errors from string coercion)**

When built-in parsers don't fit your needs, create custom parsers with `createParser`. Define `parse`, `serialize`, and optionally `eq` for equality checking.

**Incorrect (manual parsing in component):**

```tsx
'use client'
import { useQueryState } from 'nuqs'

interface SortState {
  id: string
  desc: boolean
}

export default function SortableTable() {
  const [sortRaw, setSortRaw] = useQueryState('sort')
  // Manual parsing scattered across component
  const sort: SortState = sortRaw
    ? { id: sortRaw.split(':')[0], desc: sortRaw.split(':')[1] === 'desc' }
    : { id: 'name', desc: false }

  const handleSort = (id: string) => {
    // Manual serialization
    setSortRaw(`${id}:${sort.id === id && !sort.desc ? 'desc' : 'asc'}`)
  }
}
```

**Correct (custom parser):**

```tsx
'use client'
import { useQueryState, createParser } from 'nuqs'

interface SortState {
  id: string
  desc: boolean
}

const parseAsSort = createParser<SortState>({
  parse(query) {
    const [id = '', direction = ''] = query.split(':')
    return { id, desc: direction === 'desc' }
  },
  serialize(value) {
    return `${value.id}:${value.desc ? 'desc' : 'asc'}`
  },
  eq(a, b) {
    return a.id === b.id && a.desc === b.desc
  }
})

export default function SortableTable() {
  const [sort, setSort] = useQueryState(
    'sort',
    parseAsSort.withDefault({ id: 'name', desc: false })
  )
  // Type-safe, reusable, with proper equality checking
}
```

Reference: [nuqs Custom Parsers](https://nuqs.dev/docs/parsers/making-your-own)

### 8.2 Implement eq Function for Object Parsers

**Impact: LOW (prevents unnecessary URL updates for equivalent objects)**

When creating custom parsers for objects, implement the `eq` function to define equality. Without it, nuqs uses reference equality, causing unnecessary URL updates for equivalent but different object instances.

**Incorrect (reference equality):**

```tsx
import { createParser } from 'nuqs'

interface Filters {
  minPrice: number
  maxPrice: number
}

const parseAsFilters = createParser<Filters>({
  parse(query) {
    const [min, max] = query.split('-').map(Number)
    return { minPrice: min, maxPrice: max }
  },
  serialize({ minPrice, maxPrice }) {
    return `${minPrice}-${maxPrice}`
  }
  // Missing eq - uses reference equality
})

// Problem: setting same values creates new object references
setFilters({ minPrice: 0, maxPrice: 100 })
setFilters({ minPrice: 0, maxPrice: 100 }) // Triggers URL update even though values are same
```

**Correct (value equality):**

```tsx
import { createParser } from 'nuqs'

interface Filters {
  minPrice: number
  maxPrice: number
}

const parseAsFilters = createParser<Filters>({
  parse(query) {
    const [min, max] = query.split('-').map(Number)
    return { minPrice: min, maxPrice: max }
  },
  serialize({ minPrice, maxPrice }) {
    return `${minPrice}-${maxPrice}`
  },
  eq(a, b) {
    return a.minPrice === b.minPrice && a.maxPrice === b.maxPrice
  }
})

// Now same values don't trigger unnecessary updates
setFilters({ minPrice: 0, maxPrice: 100 })
setFilters({ minPrice: 0, maxPrice: 100 }) // No URL update - values are equal
```

**For arrays:**

```tsx
const parseAsIdList = createParser<number[]>({
  parse(query) {
    return query.split(',').map(Number)
  },
  serialize(value) {
    return value.join(',')
  },
  eq(a, b) {
    return a.length === b.length && a.every((v, i) => v === b[i])
  }
})
```

**For nested objects:**

```tsx
import isEqual from 'lodash/isEqual' // or deep-equal

const parseAsConfig = createParser<Config>({
  parse: JSON.parse,
  serialize: JSON.stringify,
  eq: isEqual // Deep equality comparison
})
```

Reference: [nuqs Custom Parsers](https://nuqs.dev/docs/parsers/making-your-own)

### 8.3 Use Framework-Specific Adapters

**Impact: LOW (prevents URL sync failures in non-Next.js apps)**

nuqs works with multiple React frameworks through adapters. Use the correct adapter for your framework to ensure proper URL synchronization.

**Incorrect (wrong adapter for React Router):**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/next/app' // Wrong!
import { BrowserRouter } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <NuqsAdapter> {/* This won't work with React Router */}
        <Routes />
      </NuqsAdapter>
    </BrowserRouter>
  )
}
```

**Correct (React Router v6 adapter):**

```tsx
// src/main.tsx
import { NuqsAdapter } from 'nuqs/adapters/react-router/v6'
import { BrowserRouter } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <NuqsAdapter>
        <Routes />
      </NuqsAdapter>
    </BrowserRouter>
  )
}
```

**Available adapters:**

| Framework | Import Path |
|-----------|-------------|
| Next.js App Router | `nuqs/adapters/next/app` |
| Next.js Pages Router | `nuqs/adapters/next/pages` |
| React Router v6 | `nuqs/adapters/react-router/v6` |
| React Router v7 | `nuqs/adapters/react-router/v7` |
| Remix | `nuqs/adapters/remix` |
| Plain React | `nuqs/adapters/react` |
| Testing | `nuqs/adapters/testing` |

Reference: [nuqs Adapters](https://nuqs.dev/docs/adapters)

### 8.4 Use urlKeys for Shorter URLs

**Impact: LOW (reduces URL length by 50-70% for verbose params)**

Map verbose parameter names to shorter URL keys for cleaner, more shareable URLs while keeping descriptive names in code.

**Incorrect (verbose URL parameters):**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates({
    latitude: parseAsFloat.withDefault(0),
    longitude: parseAsFloat.withDefault(0),
    zoomLevel: parseAsInteger.withDefault(10)
  })
  // URL: ?latitude=48.8566&longitude=2.3522&zoomLevel=12
  // Long, harder to share, uses more bandwidth

  return <Map {...coords} />
}
```

**Correct (abbreviated URL keys):**

```tsx
'use client'
import { useQueryStates, parseAsFloat, parseAsInteger } from 'nuqs'

export default function MapView() {
  const [coords, setCoords] = useQueryStates(
    {
      latitude: parseAsFloat.withDefault(0),
      longitude: parseAsFloat.withDefault(0),
      zoomLevel: parseAsInteger.withDefault(10)
    },
    {
      urlKeys: {
        latitude: 'lat',
        longitude: 'lng',
        zoomLevel: 'z'
      }
    }
  )
  // URL: ?lat=48.8566&lng=2.3522&z=12
  // Shorter, cleaner URLs

  // Code still uses descriptive names
  console.log(coords.latitude, coords.longitude, coords.zoomLevel)

  return <Map {...coords} />
}
```

Reference: [nuqs urlKeys](https://nuqs.dev/docs/utilities)

---

## References

1. [https://nuqs.dev](https://nuqs.dev)
2. [https://github.com/47ng/nuqs](https://github.com/47ng/nuqs)
3. [https://nextjs.org/docs](https://nextjs.org/docs)
4. [https://react.dev](https://react.dev)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |