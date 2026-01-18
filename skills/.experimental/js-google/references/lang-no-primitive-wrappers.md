---
title: Never Use Primitive Wrapper Objects
impact: CRITICAL
impactDescription: prevents type confusion and equality bugs
tags: lang, primitives, wrapper-objects, boolean, number, string
---

## Never Use Primitive Wrapper Objects

Never instantiate primitive wrapper objects (`new Boolean()`, `new Number()`, `new String()`). They create objects instead of primitives, causing confusing truthiness and equality behavior.

**Incorrect (wrapper objects cause bugs):**

```javascript
function checkUserStatus(isActive) {
  const status = new Boolean(isActive);

  if (status) {  // Always truthy because it's an object!
    return 'User is active';
  }
  return 'User is inactive';
}

const emptyString = new String('');
if (emptyString) {  // Truthy! Object, not empty string
  console.log('This always runs');
}

const zero = new Number(0);
console.log(zero === 0);  // false (object !== primitive)
```

**Correct (use primitives directly):**

```javascript
function checkUserStatus(isActive) {
  const status = Boolean(isActive);  // Coercion, not construction

  if (status) {
    return 'User is active';
  }
  return 'User is inactive';
}

const emptyString = '';
if (emptyString) {  // Falsy as expected
  console.log('This never runs');
}

const zero = 0;
console.log(zero === 0);  // true
```

**Allowed (function calls for coercion):**

```javascript
const boolValue = Boolean(someValue);  // OK - coerces to primitive
const numValue = Number(inputString);  // OK - coerces to primitive
const strValue = String(numericId);    // OK - coerces to primitive
```

Reference: [Google JavaScript Style Guide - Wrapper objects](https://google.github.io/styleguide/jsguide.html#disallowed-features-wrapper-objects)
