---
title: Memoize Expensive Computations with useMemo
impact: MEDIUM
impactDescription: avoids recalculating on every render
tags: render, useMemo, computation, optimization, hooks
---

## Memoize Expensive Computations with useMemo

Expensive calculations should only run when their inputs change, not on every render.

**Incorrect (recalculates every render):**

```tsx
function ProductList({ products, filters }) {
  // Runs on EVERY render, even if products/filters unchanged
  const filteredProducts = products
    .filter(p => p.category === filters.category)
    .filter(p => p.price >= filters.minPrice && p.price <= filters.maxPrice)
    .sort((a, b) => a.price - b.price)

  // Also runs every render
  const stats = {
    total: filteredProducts.length,
    avgPrice: filteredProducts.reduce((sum, p) => sum + p.price, 0) / filteredProducts.length,
    categories: [...new Set(filteredProducts.map(p => p.category))],
  }

  return <List data={filteredProducts} stats={stats} />
}
```

**Correct (memoized calculations):**

```tsx
function ProductList({ products, filters }) {
  // Only recalculates when products or filters change
  const filteredProducts = useMemo(() => {
    return products
      .filter(p => p.category === filters.category)
      .filter(p => p.price >= filters.minPrice && p.price <= filters.maxPrice)
      .sort((a, b) => a.price - b.price)
  }, [products, filters])

  // Only recalculates when filteredProducts changes
  const stats = useMemo(() => ({
    total: filteredProducts.length,
    avgPrice: filteredProducts.reduce((sum, p) => sum + p.price, 0) / filteredProducts.length,
    categories: [...new Set(filteredProducts.map(p => p.category))],
  }), [filteredProducts])

  return <List data={filteredProducts} stats={stats} />
}
```

**Memoize derived data for lists:**

```tsx
function ContactList({ contacts, searchQuery }) {
  const filteredContacts = useMemo(() => {
    if (!searchQuery) return contacts

    const query = searchQuery.toLowerCase()
    return contacts.filter(contact =>
      contact.name.toLowerCase().includes(query) ||
      contact.email.toLowerCase().includes(query)
    )
  }, [contacts, searchQuery])

  const groupedContacts = useMemo(() => {
    return filteredContacts.reduce((groups, contact) => {
      const letter = contact.name[0].toUpperCase()
      groups[letter] = groups[letter] || []
      groups[letter].push(contact)
      return groups
    }, {})
  }, [filteredContacts])

  return <SectionList sections={groupedContacts} />
}
```

**Create stable object references:**

```tsx
function Chart({ data, config }) {
  // Without useMemo, new object on every render
  // breaks memo() on child components
  const chartConfig = useMemo(() => ({
    ...defaultConfig,
    ...config,
    colors: generateColors(data.length),
  }), [config, data.length])

  return <MemoizedChartComponent config={chartConfig} data={data} />
}
```

**When to use useMemo:**
- Filtering/sorting large arrays
- Complex calculations (statistics, transforms)
- Creating objects passed to memoized children
- Expensive string operations

**When NOT to use useMemo:**
- Simple calculations (cost of memo > calculation)
- Values that change every render anyway
- Primitive values (strings, numbers)

Reference: [React useMemo Documentation](https://react.dev/reference/react/useMemo)
