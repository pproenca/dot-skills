---
title: Use Consistent Vocabulary
impact: HIGH
impactDescription: eliminates confusion from synonyms and reduces mental mapping
tags: name, consistency, vocabulary, ubiquitous-language
---

## Use Consistent Vocabulary

Pick one word for each concept and stick to it throughout the codebase. Mixing synonyms forces readers to wonder if different words mean different things.

**Incorrect (inconsistent terms for same concept):**

```typescript
class UserController {
  fetchUser(id: string): User { /* ... */ }
}

class ProductController {
  getProduct(id: string): Product { /* ... */ }
}

class OrderController {
  retrieveOrder(id: string): Order { /* ... */ }
}

// Elsewhere in the codebase
const customer = loadCustomer(id)  // Is 'customer' different from 'user'?
const buyer = getBuyer(id)  // Another synonym?

// Data layer uses yet another term
class UserRepository {
  findById(id: string): User { /* ... */ }
}
```

**Correct (consistent vocabulary throughout):**

```typescript
// Pick 'get' for all retrieval operations
class UserController {
  getUser(id: string): User { /* ... */ }
}

class ProductController {
  getProduct(id: string): Product { /* ... */ }
}

class OrderController {
  getOrder(id: string): Order { /* ... */ }
}

// Consistent term for the entity
const user = getUser(id)  // Always 'user', never 'customer' or 'buyer'

// Repository layer follows same convention
class UserRepository {
  getById(id: string): User { /* ... */ }
}
```

**Establish conventions for:**
- CRUD operations: `create/get/update/delete` or `add/fetch/modify/remove`
- Collections: `list/find/search/filter` - pick one set
- Status changes: `activate/deactivate` or `enable/disable`
- Entity names: `user` vs `customer` vs `account`

Reference: [Domain-Driven Design - Ubiquitous Language](https://martinfowler.com/bliki/UbiquitousLanguage.html)
