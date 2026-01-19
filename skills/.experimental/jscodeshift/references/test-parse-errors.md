---
title: Test for Parse Error Handling
impact: MEDIUM
impactDescription: prevents transform crashes on malformed files
tags: test, parse-errors, error-handling, robustness
---

## Test for Parse Error Handling

Codemods may encounter files with syntax errors or unsupported syntax. Handle parse errors gracefully instead of crashing.

**Incorrect (crashes on parse errors):**

```javascript
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source); // Throws on syntax error

  // Transform never runs if file doesn't parse
  return root.toSource();
};

// Running on file with syntax error crashes entire batch
```

**Correct (graceful error handling):**

```javascript
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  let root;
  try {
    root = j(file.source);
  } catch (error) {
    // Log error but don't crash - allows batch to continue
    console.error(`Parse error in ${file.path}: ${error.message}`);
    return undefined; // Skip this file
  }

  // Transform logic
  const calls = root.find(j.CallExpression, { callee: { name: 'target' } });

  if (calls.size() === 0) {
    return undefined;
  }

  calls.replaceWith(/* ... */);

  return root.toSource();
};
```

**Test for error handling:**

```javascript
const { applyTransform } = require('jscodeshift/dist/testUtils');
const transform = require('../transform');

test('handles syntax errors gracefully', () => {
  const malformedCode = `
    const x = {
      incomplete: true,
    // Missing closing brace
  `;

  // Should not throw
  const result = applyTransform(transform, {}, { source: malformedCode });

  // Returns undefined (no changes) instead of crashing
  expect(result).toBeUndefined();
});
```

**Note:** Always test with malformed input to ensure robustness when running on large codebases.

Reference: [jscodeshift Error Handling](https://github.com/facebook/jscodeshift#error-handling)
