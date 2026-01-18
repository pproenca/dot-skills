---
title: Place One Statement Per Line
impact: LOW
impactDescription: reduces debugging time by 2-3× with clear breakpoints
tags: format, statements, line-breaks, style
---

## Place One Statement Per Line

Each statement should be on its own line. Multiple statements on one line reduce readability and make debugging harder.

**Incorrect (multiple statements per line):**

```javascript
const width = 1; const height = 2; const depth = 3;

if (isValid) { validateOrder(); processPayment(); }

for (let i = 0; i < 10; i++) { processItem(i); logProgress(i); }

let price = 1, quantity = 2, discount = 3;  // Multiple declarations
```

**Correct (one statement per line):**

```javascript
const width = 1;
const height = 2;
const depth = 3;

if (isValid) {
  validateOrder();
  processPayment();
}

for (let i = 0; i < 10; i++) {
  processItem(i);
  logProgress(i);
}

const price = 1;
const quantity = 2;
const discount = 3;
```

**Exception (related short statements):**

```javascript
// Simple guard clause on one line is acceptable
if (!user) { return null; }

// Switch case with single return
switch (type) {
  case 'a': return processA();
  case 'b': return processB();
  default: return null;
}
```

**Variable declarations:**
- One variable per `const`/`let` declaration
- Never use comma to declare multiple variables

Reference: [Google JavaScript Style Guide - One statement per line](https://google.github.io/styleguide/jsguide.html#formatting-one-statement-per-line)
