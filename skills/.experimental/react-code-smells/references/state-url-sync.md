---
title: Move Shareable State to URL Parameters
impact: HIGH
impactDescription: enables deep linking, removes sync bugs with browser navigation
tags: state, url, search-params, shareable, refactoring
---

## Move Shareable State to URL Parameters

State that should survive refresh, be shareable, or work with browser navigation belongs in the URL, not component state.

**Code Smell Indicators:**
- Users can't share links to specific views
- Refresh loses user's position/filters
- Back button doesn't work as expected
- State duplicated between URL and useState

**Incorrect (state lost on refresh, not shareable):**

```tsx
function ProductCatalog() {
  const [category, setCategory] = useState('all')
  const [sortBy, setSortBy] = useState('price')
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')

  // User filters products, copies URL to share...
  // Friend opens link: all filters are gone!

  return (
    <div>
      <Filters
        category={category}
        onCategoryChange={setCategory}
        sortBy={sortBy}
        onSortChange={setSortBy}
        search={search}
        onSearchChange={setSearch}
      />
      <ProductGrid category={category} sortBy={sortBy} page={page} search={search} />
      <Pagination page={page} onPageChange={setPage} />
    </div>
  )
}
```

**Correct (state in URL, shareable and persistent):**

```tsx
// Using React Router
function ProductCatalog() {
  const [searchParams, setSearchParams] = useSearchParams()

  const category = searchParams.get('category') ?? 'all'
  const sortBy = searchParams.get('sort') ?? 'price'
  const page = Number(searchParams.get('page') ?? 1)
  const search = searchParams.get('q') ?? ''

  function updateParams(updates: Record<string, string>) {
    setSearchParams(prev => {
      const next = new URLSearchParams(prev)
      Object.entries(updates).forEach(([key, value]) => {
        if (value) next.set(key, value)
        else next.delete(key)
      })
      return next
    })
  }

  // URL: /products?category=electronics&sort=rating&page=2&q=phone
  // Shareable, survives refresh, works with back button

  return (
    <div>
      <Filters
        category={category}
        onCategoryChange={v => updateParams({ category: v, page: '1' })}
        sortBy={sortBy}
        onSortChange={v => updateParams({ sort: v })}
        search={search}
        onSearchChange={v => updateParams({ q: v, page: '1' })}
      />
      <ProductGrid category={category} sortBy={sortBy} page={page} search={search} />
      <Pagination page={page} onPageChange={p => updateParams({ page: String(p) })} />
    </div>
  )
}
```

**What belongs in URL:**
- Filters and search terms
- Pagination state
- Sort order
- Selected tab/view
- Modal/dialog open state (sometimes)

**What doesn't belong in URL:**
- Form input values before submission
- Hover/focus states
- Temporary UI states
- Sensitive data

**Safe transformation steps:**
1. Identify state that should be shareable/persistent
2. Replace useState with URL parameter reads
3. Replace setState with URL parameter updates
4. Add default values for missing parameters
5. Test refresh and back button behavior

Reference: [Keep Components Pure](https://react.dev/learn/keeping-components-pure)
