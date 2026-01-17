---
title: Define All Response Types Explicitly
impact: CRITICAL
impactDescription: prevents unknown/any types in generated code
tags: spec, responses, types, openapi
---

## Define All Response Types Explicitly

Define response schemas for all status codes your API returns. Missing response definitions generate `unknown` or `any` types, eliminating type safety benefits.

**Incorrect (missing response schemas):**

```yaml
paths:
  /users:
    post:
      operationId: createUser
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Created
          # No schema - generates unknown type
        '400':
          description: Bad request
          # No error schema
        '500':
          description: Server error
```

**Correct (explicit response schemas):**

```yaml
paths:
  /users:
    post:
      operationId: createUser
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Bad request
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ValidationError'
        '500':
          description: Server error
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ServerError'

components:
  schemas:
    ValidationError:
      type: object
      properties:
        message:
          type: string
        errors:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
```

**Benefits:**
- Generated hooks have proper return types
- Error handling can be type-safe
- IDE autocomplete works for all responses

Reference: [OpenAPI Responses](https://swagger.io/docs/specification/describing-responses/)
