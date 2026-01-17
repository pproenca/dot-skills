---
title: Use Unique and Descriptive operationIds
impact: CRITICAL
impactDescription: prevents duplicate function names and import collisions
tags: spec, operationId, naming, openapi
---

## Use Unique and Descriptive operationIds

Every OpenAPI operation must have a unique `operationId`. Orval uses this as the generated function and hook name. Duplicates cause compilation errors; vague names hurt discoverability.

**Incorrect (missing or vague operationIds):**

```yaml
paths:
  /users:
    get:
      summary: Get users
      # No operationId - Orval will auto-generate an ugly name
      responses:
        '200':
          description: Success
  /users/{id}:
    get:
      operationId: get  # Too vague, may collide
      responses:
        '200':
          description: Success
```

**Correct (unique, descriptive operationIds):**

```yaml
paths:
  /users:
    get:
      operationId: listUsers
      summary: Get users
      responses:
        '200':
          description: Success
  /users/{id}:
    get:
      operationId: getUserById
      summary: Get user by ID
      responses:
        '200':
          description: Success
```

**Naming convention:**
- Use camelCase: `listUsers`, `createOrder`, `deleteUserById`
- Include the resource: `getUser` not just `get`
- Include action context: `getUserById` vs `listUsers`

Reference: [OpenAPI operationId](https://www.apimatic.io/openapi/operationid)
