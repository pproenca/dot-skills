---
title: Use Strict Equality Except for Null Checks
impact: MEDIUM-HIGH
impactDescription: prevents type coercion bugs
tags: control, equality, strict, comparison
---

## Use Strict Equality Except for Null Checks

Always use strict equality (`===`/`!==`) to avoid type coercion surprises. The only exception is `== null` which conveniently checks both `null` and `undefined`.

**Incorrect (loose equality causes bugs):**

```javascript
function validateAge(age) {
  if (age == '18') {  // Coerces string to number
    return true;
  }
  return false;
}

function checkPermission(user) {
  if (user.role == true) {  // Coerces boolean
    return 'admin';
  }
  if (user.id == 0) {  // '' == 0 is true!
    return 'guest';
  }
}
```

**Correct (strict equality):**

```javascript
function validateAge(age) {
  if (age === 18) {  // No coercion, type-safe
    return true;
  }
  return false;
}

function checkPermission(user) {
  if (user.role === true) {
    return 'admin';
  }
  if (user.id === 0) {
    return 'guest';
  }
}
```

**Exception (null/undefined check):**

```javascript
// OK: == null checks both null and undefined
function processValue(value) {
  if (value == null) {
    return 'No value provided';
  }
  return `Value: ${value}`;
}

// Equivalent but more verbose:
function processValueExplicit(value) {
  if (value === null || value === undefined) {
    return 'No value provided';
  }
  return `Value: ${value}`;
}
```

Reference: [Google JavaScript Style Guide - Equality checks](https://google.github.io/styleguide/jsguide.html#features-equality-checks)
