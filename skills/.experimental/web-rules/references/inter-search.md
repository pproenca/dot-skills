---
title: Debounce Search Input by 200-300 ms and Reflect Query in the URL
impact: HIGH
impactDescription: Un-debounced search fires 5-10× the necessary requests per second; URL-less search breaks deep-linking and back-button behavior for 100% of users
tags: inter, search, debounce, url-state, searchparams, type-ahead
---

## Debounce Search Input by 200-300 ms and Reflect Query in the URL

Search input must be debounced (200-300 ms after the user stops typing) before triggering a network request. The query string lives in `?q=…` so back/forward, refresh, sharing, and SSR all work. Use `useDeferredValue` or a custom `useDebounce` hook on the client; on the server, read `searchParams` and pass it into the data fetch. Render the search input as a Client Component, but render the results as a Server Component when possible.

**Incorrect (every keystroke = network call, no URL state):**

```tsx
'use client'
function Search() {
  const [q, setQ] = useState('')
  const [results, setResults] = useState<Item[]>([])
  return (
    <>
      <input
        value={q}
        onChange={async (e) => {
          setQ(e.target.value)
          const r = await fetch(`/api/search?q=${e.target.value}`).then((r) => r.json())
          setResults(r) // race conditions, no debounce, no URL state
        }}
      />
      <Results results={results} />
    </>
  )
}
```

**Correct (URL-driven, debounced, server-rendered results):**

```tsx
// app/search/page.tsx — Server Component
import { SearchInput } from './search-input'
import { SearchResults } from './search-results'

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>
}) {
  const { q = '' } = await searchParams
  return (
    <div className="space-y-4">
      <SearchInput defaultValue={q} />
      <SearchResults query={q} />
    </div>
  )
}

// app/search/search-input.tsx
'use client'
import { useRouter, usePathname, useSearchParams } from 'next/navigation'
import { useDebouncedCallback } from 'use-debounce'
import { Search } from 'lucide-react'

export function SearchInput({ defaultValue }: { defaultValue: string }) {
  const router = useRouter()
  const pathname = usePathname()
  const params = useSearchParams()

  const update = useDebouncedCallback((value: string) => {
    const next = new URLSearchParams(params)
    if (value) next.set('q', value)
    else next.delete('q')
    router.replace(`${pathname}?${next.toString()}`, { scroll: false })
  }, 250)

  return (
    <label className="relative block">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
      <input
        type="search"
        defaultValue={defaultValue}
        onChange={(e) => update(e.target.value)}
        placeholder="Search projects…"
        aria-label="Search projects"
        className="w-full rounded-md border bg-background pl-10 pr-3 h-11 text-sm"
      />
    </label>
  )
}

// app/search/search-results.tsx — Server Component, re-runs when ?q changes
export async function SearchResults({ query }: { query: string }) {
  if (!query.trim()) return null
  const results = await searchProjects(query)
  if (results.length === 0) return <EmptyState query={query} />
  return (
    <ul className="divide-y">
      {results.map((r) => (
        <li key={r.id}>
          <Link href={`/projects/${r.id}`} className="flex h-11 items-center px-3 hover:bg-accent">
            {r.name}
          </Link>
        </li>
      ))}
    </ul>
  )
}
```

**Rule:**
- Debounce by 200-300 ms (250 is the sweet spot); never fire on every keystroke
- Search query lives in `searchParams` (`?q=…`) — never `useState` alone
- Use `router.replace(..., { scroll: false })` so the back button doesn't fill with intermediate keystrokes
- Wrap the results component in `<Suspense>` keyed by `q` so streaming + cancellation work
- The input is `type="search"` (gives users a clear-button), with a visible `aria-label`

Reference: [searchParams in Next.js App Router](https://nextjs.org/docs/app/api-reference/file-conventions/page#searchparams-optional)
