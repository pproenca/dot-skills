---
title: Avoid Rebinding this
impact: HIGH
impactDescription: prevents subtle bugs from this binding issues
tags: func, this, binding, arrow-functions
---

## Avoid Rebinding this

Never use `function()` expressions that access `this`. Never rebind `this` unnecessarily. Use arrow functions or explicit parameters instead.

**Incorrect (this binding issues):**

```typescript
class Counter {
  count = 0

  // Function expression loses this context
  increment() {
    setTimeout(function() {
      this.count++  // this is undefined or wrong
    }, 1000)
  }

  // Unnecessary bind
  setupHandler() {
    button.addEventListener('click', this.handleClick.bind(this))
  }
}
```

**Correct (proper this handling):**

```typescript
class Counter {
  count = 0

  // Arrow function preserves this
  increment() {
    setTimeout(() => {
      this.count++  // this is correctly bound
    }, 1000)
  }

  // Arrow property for event handlers
  handleClick = () => {
    this.count++
  }

  setupHandler() {
    button.addEventListener('click', this.handleClick)
  }
}
```

**Alternative (explicit parameter):**

```typescript
// Pass context explicitly instead of relying on this
function processUser(user: User, logger: Logger) {
  logger.log(user.name)
}

// Instead of
class UserProcessor {
  process() {
    this.logger.log(this.user.name)  // Depends on this binding
  }
}
```

Reference: [Google TypeScript Style Guide - this](https://google.github.io/styleguide/tsguide.html#rebinding-this)
