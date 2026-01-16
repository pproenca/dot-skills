---
title: Define Reusable Schemas in Components
impact: CRITICAL
impactDescription: reduces generated code by 50-80%, enables type reuse
tags: spec, schemas, components, dry
---

## Define Reusable Schemas in Components

Define shared data structures in `components/schemas` and reference them with `$ref`. Inline schemas generate duplicate TypeScript interfaces, bloating output and breaking type consistency.

**Incorrect (inline schema definitions):**

```yaml
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object
                properties:
                  id:
                    type: string
                  email:
                    type: string
                  name:
                    type: string
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: object  # Duplicated definition
                properties:
                  id:
                    type: string
                  email:
                    type: string
                  name:
                    type: string
```

**Correct (reusable schema references):**

```yaml
components:
  schemas:
    User:
      type: object
      properties:
        id:
          type: string
        email:
          type: string
        name:
          type: string
      required:
        - id
        - email

paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
  /users/{id}:
    get:
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
```

**Benefits:**
- Single TypeScript `User` type generated once
- Changes propagate to all usages automatically
- Smaller bundle, better IDE autocomplete

Reference: [OpenAPI Components](https://swagger.io/docs/specification/components/)
