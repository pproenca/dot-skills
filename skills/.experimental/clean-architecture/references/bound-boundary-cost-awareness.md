---
title: Weigh Boundary Cost Against Ignorance Cost
impact: MEDIUM-HIGH
impactDescription: optimizes architectural investment, prevents both over and under engineering
tags: bound, cost, tradeoffs, pragmatism
---

## Weigh Boundary Cost Against Ignorance Cost

Boundaries are expensive to create and maintain, but ignoring needed boundaries becomes very expensive later. Continuously evaluate where the cost of implementing is less than the cost of ignoring.

**Incorrect (boundary everywhere - over-engineering):**

```java
// Overkill for a simple CRUD app with 3 entities

// 9 interfaces for 3 entities
interface UserRepository { }
interface UserService { }
interface UserPresenter { }
interface ProductRepository { }
interface ProductService { }
interface ProductPresenter { }
interface OrderRepository { }
interface OrderService { }
interface OrderPresenter { }

// 9 implementations
class SqlUserRepository implements UserRepository { }
class UserServiceImpl implements UserService { }
class UserPresenterImpl implements UserPresenter { }
// ... 6 more classes

// 3 factories
class UserFactory { }
class ProductFactory { }
class OrderFactory { }

// Result: 100 files for functionality that could be 20 files
// Maintenance burden exceeds benefit for small team
```

**Incorrect (no boundaries - under-engineering):**

```java
// Dangerous for a complex domain with multiple teams

class GodService {
    public void handleEverything(Request req) {
        // 2000 lines mixing:
        // - User authentication
        // - Order processing
        // - Payment handling
        // - Email notifications
        // - Report generation
    }
}

// Result: Every change risks breaking unrelated features
// No team can work independently
```

**Correct (boundaries where they matter):**

```java
// Evaluate each potential boundary:

// HIGH VALUE BOUNDARY: External payment provider
// - Changes frequently (provider updates API)
// - Risk of vendor lock-in
// - Different team might own this
interface PaymentGateway {
    PaymentResult charge(Money amount, PaymentMethod method);
}

// MEDIUM VALUE BOUNDARY: Database access
// - Might migrate databases
// - Enables testing without DB
interface OrderRepository {
    void save(Order order);
    Order findById(OrderId id);
}

// LOW VALUE - SKIP FOR NOW: Presenter/View split
// - Single frontend, single team
// - No plans to support multiple UIs
// Just put formatting in React components for now
// Add boundary later if needed

// SKIP: Separate microservices
// - Team is 5 people
// - Deployment is monolithic anyway
// - Network boundary adds latency and complexity for no benefit
```

**Decision Framework:**
| Factor | Add Boundary | Skip Boundary |
|--------|-------------|---------------|
| Change frequency | High | Low |
| Team ownership | Multiple teams | Single team |
| External dependency | Yes | No |
| Testing difficulty | Hard without boundary | Easy anyway |
| Current pain | Evident | Hypothetical |

Reference: [Clean Architecture - The Cost of Boundaries](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch25.xhtml)
