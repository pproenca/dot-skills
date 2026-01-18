---
title: No I Prefix for Interfaces
impact: MEDIUM
impactDescription: cleaner type names without Hungarian notation
tags: naming, interfaces, prefix, style
---

## No I Prefix for Interfaces

Never prefix interface names with `I` or suffix with `Interface`. TypeScript's structural typing makes these markers unnecessary.

**Incorrect (Hungarian notation):**

```typescript
interface IUser {
  name: string
  email: string
}

interface IUserService {
  getUser(id: string): IUser
}

interface UserInterface {
  name: string
}

// Leads to awkward usage
function processUser(user: IUser): void {}
```

**Correct (clean names):**

```typescript
interface User {
  name: string
  email: string
}

interface UserService {
  getUser(id: string): User
}

// Clean usage
function processUser(user: User): void {}

// Class implementing interface
class DefaultUserService implements UserService {
  getUser(id: string): User {
    return { name: 'Alice', email: 'alice@example.com' }
  }
}
```

**Why avoid prefixes:**
- TypeScript uses structural typing, not nominal
- Interfaces and types are interchangeable in many contexts
- Prefixes add noise without value
- Modern IDEs show type information on hover

Reference: [Google TypeScript Style Guide - Naming conventions](https://google.github.io/styleguide/tsguide.html#naming-style)
