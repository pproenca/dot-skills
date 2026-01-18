---
title: Use Parentheses for Type Casts
impact: MEDIUM
impactDescription: prevents Closure Compiler type errors
tags: type, jsdoc, cast, closure-compiler
---

## Use Parentheses for Type Casts

When casting types, enclose the expression in parentheses with the type annotation. This ensures the cast applies to the entire expression and is recognized by tools.

**Incorrect (ambiguous or invalid casts):**

```javascript
// Cast may not apply to full expression
const element = /** @type {!HTMLInputElement} */ document.getElementById('email');

// Unclear what is being cast
const value = /** @type {number} */ input.value * 100;

// Missing parentheses
const items = /** @type {!Array<string>} */ rawData.items;
```

**Correct (parenthesized casts):**

```javascript
// Cast clearly applies to getElementById result
const element = /** @type {!HTMLInputElement} */ (document.getElementById('email'));

// Cast applies to input.value, then multiply
const value = /** @type {number} */ (input.value) * 100;

// Clear cast of rawData.items
const items = /** @type {!Array<string>} */ (rawData.items);
```

**Alternative (with assignment):**

```javascript
// Use intermediate variable for clarity
const rawElement = document.getElementById('email');
const emailInput = /** @type {!HTMLInputElement} */ (rawElement);
emailInput.value = 'user@example.com';
```

**When to cast:**
- DOM element access when specific type is known
- JSON parsing results with known structure
- Library return types that are too generic

Reference: [Google JavaScript Style Guide - Type casts](https://google.github.io/styleguide/jsguide.html#jsdoc-type-casts)
