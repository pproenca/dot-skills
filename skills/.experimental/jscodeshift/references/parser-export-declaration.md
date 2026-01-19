---
title: Export Parser from Transform Module
impact: CRITICAL
impactDescription: prevents 100% of parser mismatch failures
tags: parser, export, module, configuration
---

## Export Parser from Transform Module

Specifying the parser via CLI is error-prone and requires every developer to remember the flag. Export the parser from the transform module to ensure consistent parsing.

**Incorrect (parser only via CLI):**

```javascript
// transform.js - no parser export
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  return root.toSource();
};

// Developers must remember: jscodeshift --parser=tsx -t transform.js src/
// Forgetting --parser=tsx breaks the entire run
```

**Correct (parser exported from module):**

```javascript
// transform.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  return root.toSource();
};

// Parser is bundled with the transform - no CLI flag needed
module.exports.parser = 'tsx';
```

**Benefits:**
- Transform is self-contained and portable
- No CLI flag required for correct behavior
- Reduces human error when running codemods
- Documentation and implementation stay together

Reference: [jscodeshift - Specifying Parser in Transform](https://github.com/facebook/jscodeshift#parser)
