---
title: Use Flow Parser for Flow-Typed Code
impact: CRITICAL
impactDescription: prevents parse failures on Flow type annotations
tags: parser, flow, type-annotations, configuration
---

## Use Flow Parser for Flow-Typed Code

Flow type annotations require the flow parser. Using babel or babylon parsers causes syntax errors on Flow-specific syntax like `opaque type` or `$Exact`.

**Incorrect (babel parser on Flow code):**

```javascript
// transform.js - processes files with Flow annotations
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  // Fails on: opaque type ID = string;
  return root.toSource();
};
```

**Correct (Flow parser specified):**

```javascript
// transform.js
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);
  return root.toSource();
};

module.exports.parser = 'flow';
```

**Alternative (custom parser config):**

```javascript
// flow-parser-config.json
{
  "enums": true,
  "esproposal_decorators": "ignore",
  "esproposal_class_static_fields": "enable"
}
```

```bash
jscodeshift --parser=flow --parser-config=flow-parser-config.json -t transform.js src/
```

Reference: [jscodeshift - Parser Options](https://github.com/facebook/jscodeshift#parser)
