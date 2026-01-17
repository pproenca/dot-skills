---
title: Introduce Parameter Object
impact: CRITICAL
impactDescription: reduces parameter count and enables behavior grouping
tags: struct, parameter-object, data-clumps, api-design
---

## Introduce Parameter Object

When multiple parameters frequently appear together, bundle them into a single object. This simplifies signatures and provides a home for related behavior.

**Incorrect (long parameter list with data clumps):**

```typescript
function searchProducts(
  minPrice: number,
  maxPrice: number,
  category: string,
  inStock: boolean,
  sortBy: string,
  sortOrder: 'asc' | 'desc',
  page: number,
  pageSize: number
): Product[] {
  // Implementation
}

function countProducts(
  minPrice: number,
  maxPrice: number,
  category: string,
  inStock: boolean
): number {
  // Same filter params repeated
}

// Calling code is hard to read
const products = searchProducts(10, 100, 'electronics', true, 'price', 'asc', 1, 20)
```

**Correct (parameter object with behavior):**

```typescript
interface ProductFilter {
  minPrice?: number
  maxPrice?: number
  category?: string
  inStock?: boolean
}

interface PaginationOptions {
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
  page?: number
  pageSize?: number
}

function searchProducts(filter: ProductFilter, pagination: PaginationOptions): Product[] {
  // Implementation
}

function countProducts(filter: ProductFilter): number {
  // Reuses same filter type
}

// Calling code is self-documenting
const filter: ProductFilter = { minPrice: 10, maxPrice: 100, category: 'electronics', inStock: true }
const pagination: PaginationOptions = { sortBy: 'price', sortOrder: 'asc', page: 1, pageSize: 20 }
const products = searchProducts(filter, pagination)
```

**Alternative (class with validation):**

```typescript
class ProductFilter {
  constructor(
    public minPrice?: number,
    public maxPrice?: number,
    public category?: string,
    public inStock?: boolean
  ) {
    this.validate()
  }

  private validate(): void {
    if (this.minPrice !== undefined && this.maxPrice !== undefined && this.minPrice > this.maxPrice) {
      throw new Error('minPrice cannot exceed maxPrice')
    }
  }

  hasPrice(): boolean {
    return this.minPrice !== undefined || this.maxPrice !== undefined
  }
}
```

**Benefits:**
- Related parameters travel together
- Validation logic has a natural home
- Adding new parameters doesn't change function signatures

Reference: [Introduce Parameter Object](https://refactoring.com/catalog/introduceParameterObject.html)
