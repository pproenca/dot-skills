---
title: Avoid Decorative Underscores
impact: MEDIUM
impactDescription: cleaner code without misleading conventions
tags: naming, underscores, private, style
---

## Avoid Decorative Underscores

Never use leading or trailing underscores for identifiers. Use TypeScript's `private` modifier for private members instead.

**Incorrect (decorative underscores):**

```typescript
class UserService {
  _users: User[] = []  // Leading underscore for "private"
  __internalState = {}  // Double underscore
  users_ = []  // Trailing underscore

  _loadUsers() {
    // Leading underscore for "private" method
  }
}

// Underscore prefix for unused variables
function process(_unused: string, value: number) {
  return value * 2
}
```

**Correct (TypeScript modifiers):**

```typescript
class UserService {
  private users: User[] = []
  private internalState = {}

  private loadUsers() {
    // Truly private with TypeScript
  }
}

// Omit unused parameters or use explicit void
function process(value: number) {
  return value * 2
}

// Or use void for required unused params
function callback(_event: Event) {
  // Parameter required by signature but unused
  void _event  // Explicit acknowledgment
}
```

**Exception - external API requirements:**

```typescript
// Some external libraries require specific naming
interface WindowWithGlobals extends Window {
  __REDUX_DEVTOOLS_EXTENSION__?: DevToolsExtension
}
```

Reference: [Google TypeScript Style Guide - Naming conventions](https://google.github.io/styleguide/tsguide.html#naming-style)
