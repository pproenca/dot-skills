---
title: Freeze Constant Collections
impact: CRITICAL
impactDescription: prevents repeated allocation of identical objects
tags: alloc, freeze, constants, immutable
---

## Freeze Constant Collections

Ruby re-evaluates array and hash literals assigned to constants each time they are referenced in certain contexts. Without `.freeze`, accidental mutation can corrupt shared state, and the interpreter cannot optimize access. Freezing enables the VM to reuse the same object safely.

**Incorrect (mutable constants, risk of corruption and extra allocations):**

```ruby
class ProductCatalog
  ALLOWED_CATEGORIES = ["electronics", "clothing", "home", "garden"]
  DEFAULT_FILTERS = { in_stock: true, min_rating: 3.0 }
  SORT_OPTIONS = [:price_asc, :price_desc, :newest, :rating]

  def filter_products(products, category:)
    unless ALLOWED_CATEGORIES.include?(category)
      raise ArgumentError, "invalid category"
    end

    filters = DEFAULT_FILTERS  # Shares the mutable reference
    filters[:category] = category  # Mutates the constant for all callers
    apply_filters(products, filters)
  end
end
```

**Correct (frozen constants, immutable and safe):**

```ruby
class ProductCatalog
  ALLOWED_CATEGORIES = ["electronics", "clothing", "home", "garden"].freeze
  DEFAULT_FILTERS = { in_stock: true, min_rating: 3.0 }.freeze
  SORT_OPTIONS = [:price_asc, :price_desc, :newest, :rating].freeze

  def filter_products(products, category:)
    unless ALLOWED_CATEGORIES.include?(category)
      raise ArgumentError, "invalid category"
    end

    filters = DEFAULT_FILTERS.merge(category: category)  # Returns a new hash
    apply_filters(products, filters)
  end
end
```

**Deep freeze nested structures:**

```ruby
SHIPPING_RATES = {
  domestic: { standard: 5.99, express: 12.99 }.freeze,
  international: { standard: 19.99, express: 39.99 }.freeze
}.freeze
```
