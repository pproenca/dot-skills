---
title: Prefer Duplication Over Premature Abstraction
impact: MEDIUM
impactDescription: Wrong abstractions cost 3-10x more to fix than duplicated code, and force unrelated code to change together
tags: dup, abstraction, coupling, maintainability
---

## Prefer Duplication Over Premature Abstraction

Three similar lines of code are often better than a premature abstraction. The wrong abstraction creates coupling between unrelated concepts, making future changes ripple across the codebase. Duplication is cheap to fix later when you understand the true pattern; bad abstractions are expensive to unwind because other code depends on them.

**Incorrect (premature abstraction couples unrelated concepts):**

```typescript
// "Both format currency, let's make it generic!"
function formatValue(value: number, type: 'price' | 'salary' | 'discount'): string {
  const symbol = type === 'discount' ? '-$' : '$';
  const decimals = type === 'salary' ? 0 : 2;
  const prefix = type === 'price' ? '' : ' ';

  return `${prefix}${symbol}${value.toFixed(decimals)}`;
}

// Now price formatting changes require checking salary and discount logic
// And discount needs a negative sign but price doesn't
// The abstraction becomes a mess of special cases
```

**Correct (explicit duplication until patterns emerge):**

```typescript
function formatPrice(cents: number): string {
  return `$${(cents / 100).toFixed(2)}`;
}

function formatSalary(annual: number): string {
  return `$${annual.toLocaleString()}`;
}

function formatDiscount(cents: number): string {
  return `-$${(cents / 100).toFixed(2)}`;
}

// Each can evolve independently
// formatPrice might add currency symbols later
// formatSalary might add "per year" suffix
// formatDiscount might show percentage instead
```

**Incorrect (abstraction forces unrelated code to change together):**

```python
class EntityProcessor:
    """Processes users, orders, and products - they're all 'entities'!"""

    def process(self, entity, entity_type):
        if entity_type == 'user':
            self._validate_user(entity)
            self._save_user(entity)
        elif entity_type == 'order':
            self._validate_order(entity)
            self._calculate_totals(entity)
            self._save_order(entity)
        elif entity_type == 'product':
            self._validate_product(entity)
            self._update_inventory(entity)
            self._save_product(entity)

# Adding a new entity type or changing one affects this god class
# User processing doesn't need inventory; order doesn't need user validation
```

**Correct (separate concerns, accept some duplication):**

```python
class UserService:
    def create_user(self, data):
        self._validate(data)
        return self.repository.save(data)

class OrderService:
    def create_order(self, data):
        self._validate(data)
        self._calculate_totals(data)
        return self.repository.save(data)

class ProductService:
    def create_product(self, data):
        self._validate(data)
        self._update_inventory(data)
        return self.repository.save(data)

# Yes, each has _validate and save - that's okay
# They can diverge without affecting each other
```

**Incorrect (abstracting over superficial similarity):**

```go
// "Both take a slice and return one element!"
func getOne[T any](items []T, selector func([]T) T) T {
    return selector(items)
}

// Callers become puzzling
first := getOne(users, func(u []User) User { return u[0] })
last := getOne(orders, func(o []Order) Order { return o[len(o)-1] })
random := getOne(products, func(p []Product) Product {
    return p[rand.Intn(len(p))]
})
```

**Correct (just write the simple code):**

```go
first := users[0]
last := orders[len(orders)-1]
random := products[rand.Intn(len(products))]

// Obvious, no abstraction needed
```

**Incorrect (DRY violation fear leads to tight coupling):**

```javascript
// Shared validation "to avoid duplication"
const sharedValidation = {
  validateEmail: (email) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email),
  validatePhone: (phone) => /^\d{10}$/.test(phone),
};

// Now used by User, Contact, Company, Lead...
// Phone validation needs to change for international numbers
// But only for Company and Lead, not User
// The "shared" code becomes a liability
```

**Correct (duplicate until requirements clarify):**

```javascript
// User module
function validateUserPhone(phone) {
  return /^\d{10}$/.test(phone); // US only for users
}

// Company module
function validateCompanyPhone(phone) {
  return /^\+?[\d\s-]{10,}$/.test(phone); // International for business
}

// When you KNOW they should be the same, then extract
```

### The Sandi Metz Rule

"Duplication is far cheaper than the wrong abstraction." If you're unsure whether code should be shared:

1. Duplicate it
2. Wait for the third occurrence
3. Look for the true underlying pattern
4. Then extract with confidence

### When Abstraction IS Appropriate

- Business rule that must be consistent (tax calculation, authentication)
- Algorithm that is complex and needs isolated testing
- Pattern that has appeared 3+ times with identical structure
- Domain concept with a clear name in the ubiquitous language

### Benefits

- Code changes are localized to one area
- New requirements don't break unrelated features
- Easier to understand - each module is self-contained
- Refactoring is straightforward when patterns emerge
