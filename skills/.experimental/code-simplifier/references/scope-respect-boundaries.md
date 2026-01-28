---
title: Respect Module and Component Boundaries
impact: HIGH
impactDescription: Cross-boundary changes require multiple team approvals, increase coupling by 30%, and double the testing surface area
tags: scope, boundaries, modules, coupling, encapsulation
---

## Respect Module and Component Boundaries

When simplifying code, stay within the current module or component boundary. Reaching across boundaries to "simplify" creates tight coupling, violates encapsulation, and pulls in reviewers from other teams. Each module has its own owners, contracts, and release cycles.

**Incorrect (crossing boundaries to simplify):**

```typescript
// Task: Simplify the OrderService in the orders module
// "I can simplify this by directly accessing the user database"

// orders/OrderService.ts
import { db } from '../users/database';        // Crossing into users module!
import { UserCache } from '../users/cache';    // Crossing into users module!
import { formatAddress } from '../shipping/utils'; // Crossing into shipping!

class OrderService {
  async createOrder(userId: string, items: Item[]) {
    // "Simplified" by bypassing UserService
    const user = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    const cached = UserCache.get(userId);  // Direct cache access

    // "Simplified" by inlining shipping logic
    const address = formatAddress(user.address); // Using internal util

    return this.repo.create({ user, items, address });
  }
}

// Now OrderService depends on:
// - users module internals (database, cache)
// - shipping module internals (utils)
// Breaking changes in any module will break orders
```

**Correct (respecting boundaries):**

```typescript
// Task: Simplify the OrderService in the orders module
// Stays within orders module, uses public APIs

// orders/OrderService.ts
import { UserService } from '../users';      // Public API only
import { ShippingService } from '../shipping'; // Public API only

class OrderService {
  constructor(
    private users: UserService,
    private shipping: ShippingService,
    private repo: OrderRepository
  ) {}

  async createOrder(userId: string, items: Item[]) {
    // Before: verbose null checking
    const user = await this.users.getById(userId);
    if (!user) throw new NotFoundError('User not found');

    const address = await this.shipping.formatAddress(user.addressId);
    if (!address) throw new NotFoundError('Address not found');

    return this.repo.create({ userId, items, shippingAddress: address });
  }

  // After: simplified but still uses public APIs
  async createOrder(userId: string, items: Item[]) {
    const [user, address] = await Promise.all([
      this.users.getByIdOrThrow(userId),
      this.shipping.getFormattedAddress(userId)
    ]);

    return this.repo.create({ userId, items, shippingAddress: address });
  }
}

// If UserService or ShippingService APIs are clunky, request changes
// through proper channels - don't bypass them
```

### Boundary Violations to Avoid

| Violation | Why It's Harmful |
|-----------|-----------------|
| Direct database access across modules | Bypasses business logic, breaks encapsulation |
| Importing internal utilities | Creates hidden dependencies |
| Accessing private/internal APIs | Will break on internal refactors |
| Copying code from other modules | Creates drift and duplication |
| Modifying other modules "to simplify" | Requires other team's review/approval |

### When NOT to Apply

- When you own both modules and they're tightly related
- When the boundary itself is the problem (propose boundary changes separately)
- When working in a monolith with no clear module ownership
- When the public API is genuinely missing needed functionality (request it)

### Benefits

- Each module can evolve independently
- Changes only require review from affected team
- Testing is scoped to the current module
- Coupling stays low and explicit
