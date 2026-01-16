---
title: Test Edge Cases and Boundaries
impact: CRITICAL
impactDescription: catches 60-80% of production bugs
tags: design, edge-cases, boundaries, error-handling
---

## Test Edge Cases and Boundaries

Happy path tests alone miss most bugs. Explicitly test boundaries, empty states, error conditions, and unusual inputs where bugs typically hide.

**Incorrect (happy path only):**

```typescript
test('paginates results', () => {
  const items = createItems(100)
  const result = paginate(items, { page: 1, pageSize: 10 })

  expect(result.items).toHaveLength(10)
  expect(result.totalPages).toBe(10)
})
// Works for normal case, crashes in production on edge cases
```

**Correct (comprehensive edge case coverage):**

```typescript
describe('paginate', () => {
  // Happy path
  it('returns requested page of items', () => {
    const items = createItems(100)
    const result = paginate(items, { page: 2, pageSize: 10 })
    expect(result.items).toHaveLength(10)
    expect(result.currentPage).toBe(2)
  })

  // Empty state
  it('returns empty array when no items exist', () => {
    const result = paginate([], { page: 1, pageSize: 10 })
    expect(result.items).toEqual([])
    expect(result.totalPages).toBe(0)
  })

  // Boundary: last page partial
  it('returns partial page when items dont fill last page', () => {
    const items = createItems(25)
    const result = paginate(items, { page: 3, pageSize: 10 })
    expect(result.items).toHaveLength(5)
  })

  // Boundary: page beyond range
  it('returns empty array when page exceeds total pages', () => {
    const items = createItems(10)
    const result = paginate(items, { page: 5, pageSize: 10 })
    expect(result.items).toEqual([])
  })

  // Invalid input
  it('throws when page is zero or negative', () => {
    expect(() => paginate([], { page: 0, pageSize: 10 })).toThrow()
    expect(() => paginate([], { page: -1, pageSize: 10 })).toThrow()
  })

  // Boundary: single item
  it('handles single item correctly', () => {
    const items = createItems(1)
    const result = paginate(items, { page: 1, pageSize: 10 })
    expect(result.items).toHaveLength(1)
    expect(result.totalPages).toBe(1)
  })
})
```

**Edge case checklist:**
- Empty collections
- Single item
- Maximum values
- Zero and negative numbers
- Null/undefined inputs
- Boundary conditions (off-by-one)
- Concurrent access

Reference: [Test Driven Development by Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)
