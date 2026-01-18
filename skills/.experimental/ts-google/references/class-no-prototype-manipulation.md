---
title: Never Manipulate Prototypes Directly
impact: HIGH
impactDescription: prevents VM deoptimization and unpredictable behavior
tags: class, prototype, inheritance, anti-pattern
---

## Never Manipulate Prototypes Directly

Never modify prototypes directly. It breaks VM optimizations, creates unpredictable behavior, and makes code difficult to understand.

**Incorrect (prototype manipulation):**

```typescript
// Extending built-in prototypes
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1)
}

// Dynamic prototype modification
function User(name: string) {
  this.name = name
}
User.prototype.greet = function() {
  return `Hello, ${this.name}`
}

// Modifying prototype chain
Object.setPrototypeOf(child, parent)
```

**Correct (use classes or composition):**

```typescript
// Utility function instead of prototype extension
function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1)
}

// Class-based inheritance
class User {
  constructor(public name: string) {}

  greet(): string {
    return `Hello, ${this.name}`
  }
}

// Composition for shared behavior
class UserWithLogging {
  constructor(
    private user: User,
    private logger: Logger
  ) {}

  greet(): string {
    this.logger.log('greet called')
    return this.user.greet()
  }
}
```

**Why avoid prototype manipulation:**
- Breaks VM hidden class optimizations
- Pollutes global scope
- Creates maintenance nightmares
- Incompatible with strict mode in some cases

Reference: [Google TypeScript Style Guide - Modifying prototypes](https://google.github.io/styleguide/tsguide.html#disallowed-features)
