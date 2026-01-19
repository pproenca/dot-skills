---
title: Use defineInlineTest for Input/Output Verification
impact: MEDIUM
impactDescription: catches 95%+ transform regressions automatically
tags: test, inline, snapshots, verification
---

## Use defineInlineTest for Input/Output Verification

jscodeshift provides `defineInlineTest` for testing transforms with inline input/output strings. This makes test cases self-documenting.

**Incorrect (external file-based tests):**

```javascript
// Hard to see what the transform does
// test/__testfixtures__/transform.input.js
// test/__testfixtures__/transform.output.js

test('transform works', () => {
  // Requires opening multiple files to understand test
});
```

**Correct (inline test with clear before/after):**

```javascript
const { defineInlineTest } = require('jscodeshift/dist/testUtils');
const transform = require('../transform');

defineInlineTest(
  transform,
  {}, // options
  // Input
  `
import { oldFunc } from 'old-module';

const result = oldFunc(data);
  `,
  // Expected output
  `
import { newFunc } from 'new-module';

const result = newFunc(data);
  `,
  'renames oldFunc import to newFunc'
);
```

**Testing edge cases:**

```javascript
// Test: transform does NOT modify unrelated code
defineInlineTest(
  transform,
  {},
  `
import { otherFunc } from 'other-module';
const result = otherFunc(data);
  `,
  `
import { otherFunc } from 'other-module';
const result = otherFunc(data);
  `,
  'leaves unrelated imports unchanged'
);

// Test: handles aliased imports
defineInlineTest(
  transform,
  {},
  `
import { oldFunc as myFunc } from 'old-module';
const result = myFunc(data);
  `,
  `
import { newFunc as myFunc } from 'new-module';
const result = myFunc(data);
  `,
  'handles aliased imports'
);
```

Reference: [jscodeshift - Testing](https://jscodeshift.com/run/testing/)
