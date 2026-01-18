---
title: Always Use Explicit Semicolons
impact: HIGH
impactDescription: prevents ASI-related parsing errors
tags: lang, semicolons, asi, syntax
---

## Always Use Explicit Semicolons

Always terminate statements with semicolons. Relying on Automatic Semicolon Insertion (ASI) causes subtle parsing errors, especially with line-starting parentheses, brackets, or template literals.

**Incorrect (ASI causes unexpected behavior):**

```javascript
const getUser = () => ({ name: 'Alice' })
const processUser = (user) => console.log(user)

// ASI fails here - parsed as getUser()(processUser)
const user = getUser()
(processUser)(user)

// Another ASI pitfall
const message = 'Hello'
['error', 'warn'].forEach(level => console[level](message))
// Parsed as: 'Hello'['error', 'warn'].forEach(...)
```

**Correct (explicit semicolons):**

```javascript
const getUser = () => ({ name: 'Alice' });
const processUser = (user) => console.log(user);

const user = getUser();
processUser(user);

const message = 'Hello';
['error', 'warn'].forEach(level => console[level](message));
```

**Dangerous line starters:**
- `(` - parenthesis
- `[` - bracket
- `` ` `` - template literal
- `/` - regex or division
- `+` or `-` - unary operators

Reference: [Google JavaScript Style Guide - Semicolons are required](https://google.github.io/styleguide/jsguide.html#formatting-semicolons-are-required)
