---
title: Use useCallback for Stable Event Handlers
impact: MEDIUM
impactDescription: prevents unnecessary re-renders of memoized children on every parent render
tags: client, useCallback, memoization, performance, event-handlers
---

## Use useCallback for Stable Event Handlers

Functions created inside components get new references on every render. When passed as props to memoized children or used in dependency arrays, these unstable references trigger unnecessary re-renders and effect re-runs.

**Incorrect (unstable callback reference):**

```tsx
'use client'

import { memo, useState } from 'react'

function FilterPanel({ filters, onFilterChange }: FilterPanelProps) {
  const [searchQuery, setSearchQuery] = useState('')

  const handleCategorySelect = (category: string) => {
    onFilterChange({ ...filters, category })
  }
  // New function created every render, defeats memo below

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <CategoryList
        categories={filters.availableCategories}
        onSelect={handleCategorySelect}
      />
    </div>
  )
}

const CategoryList = memo(function CategoryList({
  categories,
  onSelect,
}: CategoryListProps) {
  // Re-renders on every FilterPanel render despite memo
  return (
    <ul>
      {categories.map((cat) => (
        <li key={cat} onClick={() => onSelect(cat)}>{cat}</li>
      ))}
    </ul>
  )
})
```

**Correct (stable callback with useCallback):**

```tsx
'use client'

import { memo, useState, useCallback } from 'react'

function FilterPanel({ filters, onFilterChange }: FilterPanelProps) {
  const [searchQuery, setSearchQuery] = useState('')

  const handleCategorySelect = useCallback((category: string) => {
    onFilterChange({ ...filters, category })
  }, [filters, onFilterChange])

  return (
    <div>
      <SearchInput value={searchQuery} onChange={setSearchQuery} />
      <CategoryList
        categories={filters.availableCategories}
        onSelect={handleCategorySelect}
      />
    </div>
  )
}

const CategoryList = memo(function CategoryList({
  categories,
  onSelect,
}: CategoryListProps) {
  // Only re-renders when categories or onSelect actually change
  return (
    <ul>
      {categories.map((cat) => (
        <li key={cat} onClick={() => onSelect(cat)}>{cat}</li>
      ))}
    </ul>
  )
})
```

**When NOT to use:** For simple components without memoized children or effects depending on the callback, the overhead of useCallback may not be worth the added complexity.

Reference: [React useCallback](https://react.dev/reference/react/useCallback)
