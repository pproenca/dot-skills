---
title: Use Parameter Properties for Constructor Assignment
impact: HIGH
impactDescription: reduces boilerplate by 50%
tags: class, constructor, parameter-properties, boilerplate
---

## Use Parameter Properties for Constructor Assignment

Use parameter properties to combine parameter declaration and property assignment into a single declaration, eliminating boilerplate.

**Incorrect (manual assignment):**

```typescript
class UserService {
  private readonly httpClient: HttpClient
  private readonly logger: Logger
  private readonly config: Config

  constructor(
    httpClient: HttpClient,
    logger: Logger,
    config: Config
  ) {
    this.httpClient = httpClient
    this.logger = logger
    this.config = config
  }
}
```

**Correct (parameter properties):**

```typescript
class UserService {
  constructor(
    private readonly httpClient: HttpClient,
    private readonly logger: Logger,
    private readonly config: Config
  ) {}
}
```

**Rules for parameter properties:**
- Use `private readonly` for dependencies (most common)
- Use `public readonly` for immutable public properties
- Use `protected readonly` for properties needed by subclasses
- Never use `public` without `readonly` (exposes mutable state)

Reference: [Google TypeScript Style Guide - Parameter properties](https://google.github.io/styleguide/tsguide.html#parameter-properties)
