---
title: Write Negative Test Cases First
impact: MEDIUM
impactDescription: prevents unintended transformations before they happen
tags: test, negative-cases, safety, tdd
---

## Write Negative Test Cases First

Write tests for code that should NOT be transformed before writing positive tests. This catches overly aggressive transforms early.

**Incorrect (only positive tests):**

```javascript
// Only tests what SHOULD change
defineInlineTest(
  transform,
  {},
  `import { useState } from 'react';`,
  `import { useState } from 'preact/hooks';`,
  'transforms react to preact'
);

// But doesn't verify: Does it leave non-react imports alone?
// Does it handle aliased imports correctly?
```

**Correct (negative tests first):**

```javascript
// First: Verify what should NOT change
defineInlineTest(
  transform,
  {},
  `import { useState } from 'preact/hooks';`,
  `import { useState } from 'preact/hooks';`,
  'leaves preact imports unchanged'
);

defineInlineTest(
  transform,
  {},
  `import { useState } from './local-hooks';`,
  `import { useState } from './local-hooks';`,
  'leaves local imports unchanged'
);

defineInlineTest(
  transform,
  {},
  `
const react = require('react');
const { useState } = react;
  `,
  `
const react = require('react');
const { useState } = react;
  `,
  'does not transform require() calls'
);

// Then: Positive test cases
defineInlineTest(
  transform,
  {},
  `import { useState } from 'react';`,
  `import { useState } from 'preact/hooks';`,
  'transforms react to preact'
);
```

**Test case categories to cover:**

1. **Similar but different** - Code that looks like target but isn't
2. **Different context** - Same identifier in different positions
3. **Nested structures** - Deeply nested matching patterns
4. **Edge cases** - Empty files, comments only, unusual formatting

Reference: [Refactoring with Codemods to Automate API Changes](https://martinfowler.com/articles/codemods-api-refactoring.html)
