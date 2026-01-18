---
title: Use Trailing Commas in Multi-line Literals
impact: MEDIUM
impactDescription: reduces git diff noise by 50% on additions
tags: data, arrays, objects, trailing-commas
---

## Use Trailing Commas in Multi-line Literals

Include trailing commas after the last element in multi-line array and object literals. This produces cleaner git diffs and makes reordering easier.

**Incorrect (no trailing comma, noisy diffs):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3  // Adding new property changes this line too
};

const roles = [
  'admin',
  'editor',
  'viewer'  // Adding new role changes this line
];
```

**Correct (trailing commas):**

```javascript
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,  // Adding property only adds one line
};

const roles = [
  'admin',
  'editor',
  'viewer',  // Adding role only adds one line
];
```

**Git diff comparison:**

```diff
# Without trailing comma (2 lines changed)
  const roles = [
    'admin',
    'editor',
-   'viewer'
+   'viewer',
+   'guest'
  ];

# With trailing comma (1 line changed)
  const roles = [
    'admin',
    'editor',
    'viewer',
+   'guest',
  ];
```

**When NOT to use trailing comma:**
- Single-line literals: `const point = { x: 1, y: 2 };`
- Function parameters in declarations (different rule)

Reference: [Google JavaScript Style Guide - Trailing commas](https://google.github.io/styleguide/jsguide.html#features-arrays-trailing-comma)
