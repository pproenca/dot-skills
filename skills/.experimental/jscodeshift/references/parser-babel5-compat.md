---
title: Avoid Default Babel5Compat Parser for Modern Syntax
impact: CRITICAL
impactDescription: prevents parse failures on post-ES2015 features
tags: parser, babel, compatibility, modern-syntax
---

## Avoid Default Babel5Compat Parser for Modern Syntax

jscodeshift defaults to `babel5compat` mode for backwards compatibility with old codemods. This breaks on modern syntax like optional chaining, nullish coalescing, and private class fields.

**Incorrect (relying on default parser):**

```javascript
// transform.js - no parser specified
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  // Fails on: const value = obj?.nested?.property ?? 'default';
  return root.toSource();
};
```

**Correct (explicit modern babel parser):**

```javascript
// transform.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  return root.toSource();
};

module.exports.parser = 'babel';
```

**Alternative (babylon with plugins):**

```javascript
// parser-config.json
{
  "sourceType": "module",
  "plugins": [
    "jsx",
    "optionalChaining",
    "nullishCoalescingOperator",
    "classPrivateProperties",
    "classPrivateMethods"
  ]
}
```

```bash
jscodeshift --parser=babylon --parser-config=parser-config.json -t transform.js src/
```

Reference: [jscodeshift Issue #500 - Bringing jscodeshift up to date](https://github.com/facebook/jscodeshift/issues/500)
