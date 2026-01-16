---
title: Organize Operations with Tags
impact: CRITICAL
impactDescription: enables tags-split mode, improves code organization
tags: spec, tags, organization, structure
---

## Organize Operations with Tags

Apply meaningful tags to every operation. Orval's `tags` and `tags-split` modes use these to organize generated code into logical files and folders, enabling better tree-shaking and imports.

**Incorrect (missing or inconsistent tags):**

```yaml
paths:
  /users:
    get:
      operationId: listUsers
      # No tag - goes into default bucket
      responses:
        '200':
          description: Success
  /orders:
    get:
      operationId: listOrders
      tags:
        - order  # Inconsistent casing
      responses:
        '200':
          description: Success
    post:
      operationId: createOrder
      tags:
        - Orders  # Different tag for same resource
      responses:
        '201':
          description: Created
```

**Correct (consistent, meaningful tags):**

```yaml
tags:
  - name: users
    description: User management operations
  - name: orders
    description: Order processing operations

paths:
  /users:
    get:
      operationId: listUsers
      tags:
        - users
      responses:
        '200':
          description: Success
  /orders:
    get:
      operationId: listOrders
      tags:
        - orders
      responses:
        '200':
          description: Success
    post:
      operationId: createOrder
      tags:
        - orders
      responses:
        '201':
          description: Created
```

**Generated structure with `tags-split` mode:**
```plaintext
src/gen/
├── users/
│   ├── users.ts
│   └── users.msw.ts
└── orders/
    ├── orders.ts
    └── orders.msw.ts
```

Reference: [Orval tags-split mode](https://orval.dev/reference/configuration/output)
