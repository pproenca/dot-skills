---
title: Use Fixture Files for Complex Test Cases
impact: MEDIUM
impactDescription: catches 90%+ edge cases missed by inline tests
tags: test, fixtures, files, complex-cases
---

## Use Fixture Files for Complex Test Cases

For complex transformations involving multiple patterns, use fixture files that mirror real codebase structure.

**Incorrect (oversimplified inline tests):**

```javascript
// Simple inline test doesn't reflect real complexity
defineInlineTest(
  transform,
  {},
  `import { x } from 'y';`,
  `import { x } from 'z';`,
  'transforms import'
);
// But real files have hundreds of lines with edge cases
```

**Correct (fixture files for comprehensive testing):**

```javascript
// __testfixtures__/complex-component.input.tsx
// __testfixtures__/complex-component.output.tsx

const { defineTest } = require('jscodeshift/dist/testUtils');

// Tests input.tsx → output.tsx transformation
defineTest(
  __dirname,
  'transform', // transform filename
  null, // options
  'complex-component', // fixture name (without .input/.output suffix)
  { parser: 'tsx' }
);
```

**Fixture file structure:**

```text
__tests__/
├── transform.test.js
└── __testfixtures__/
    ├── basic.input.js
    ├── basic.output.js
    ├── with-aliases.input.js
    ├── with-aliases.output.js
    ├── complex-component.input.tsx
    └── complex-component.output.tsx
```

**Combining inline and fixture tests:**

```javascript
// Use inline for simple cases (quick to read)
defineInlineTest(transform, {}, 'simple input', 'simple output', 'simple case');

// Use fixtures for complex cases (realistic scenarios)
defineTest(__dirname, 'transform', null, 'real-world-component');
defineTest(__dirname, 'transform', null, 'edge-case-module');
```

Reference: [jscodeshift - testUtils](https://jscodeshift.com/run/testing/)
