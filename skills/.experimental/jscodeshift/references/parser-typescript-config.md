---
title: Use Correct Parser for TypeScript Files
impact: CRITICAL
impactDescription: prevents 100% transform failures on TypeScript codebases
tags: parser, typescript, tsx, configuration
---

## Use Correct Parser for TypeScript Files

jscodeshift defaults to the babel parser, which cannot parse TypeScript syntax. Specify the correct parser to avoid parse failures on every file.

**Incorrect (default babel parser on TypeScript):**

```javascript
// transform.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  // Fails: SyntaxError on TypeScript syntax
  return root.toSource();
};
```

**Correct (TypeScript parser specified):**

```javascript
// transform.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  return root.toSource();
};

module.exports.parser = 'tsx'; // Handles both .ts and .tsx files
```

**Alternative (CLI flag):**

```bash
jscodeshift --parser=tsx --extensions=ts,tsx -t transform.js src/
```

**Note:** Use `tsx` parser for mixed codebases - it handles both `.ts` and `.tsx` files correctly.

Reference: [jscodeshift README - Parser](https://github.com/facebook/jscodeshift#parser)
