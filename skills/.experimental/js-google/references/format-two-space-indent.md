---
title: Use Two-Space Indentation
impact: LOW
impactDescription: maintains consistent code appearance
tags: format, indentation, whitespace, style
---

## Use Two-Space Indentation

Indent with 2 spaces per level. Never use tabs. Continuation lines should be indented at least 4 spaces from the original line.

**Incorrect (tabs or 4-space indent):**

```javascript
function processOrder(order) {
    // 4-space indent
    if (order.items) {
        for (const item of order.items) {
            validateItem(item);
        }
    }
}

function createUser(
  name,  // Only 2 spaces for continuation
  email,
  role
) {
  return { name, email, role };
}
```

**Correct (2-space indent):**

```javascript
function processOrder(order) {
  // 2-space indent
  if (order.items) {
    for (const item of order.items) {
      validateItem(item);
    }
  }
}

function createUser(
    name,  // 4-space continuation indent
    email,
    role
) {
  return { name, email, role };
}
```

**Array and object literals:**

```javascript
const config = {
  api: {
    baseUrl: 'https://api.example.com',
    timeout: 5000,
  },
  features: {
    darkMode: true,
    notifications: false,
  },
};

const items = [
  'first',
  'second',
  'third',
];
```

**Note:** Configure your editor to use spaces, not tabs. Most formatters (Prettier, clang-format) can enforce this automatically.

Reference: [Google JavaScript Style Guide - Block indentation](https://google.github.io/styleguide/jsguide.html#formatting-block-indentation)
