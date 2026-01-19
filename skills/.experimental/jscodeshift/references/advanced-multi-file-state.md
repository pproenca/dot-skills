---
title: Share State Across Files with Options
impact: LOW
impactDescription: enables cross-file analysis and coordinated transforms
tags: advanced, multi-file, state, options
---

## Share State Across Files with Options

Some transformations need information from multiple files. Use the options object and external state files for cross-file coordination.

**Incorrect (each file processed in isolation):**

```javascript
// transform.js - no cross-file awareness
module.exports = function transformer(file, api) {
  // Can't know what was exported from other files
  // Can't coordinate changes across files
};
```

**Correct (shared state via options):**

```javascript
// First pass: collect information
// collect-exports.js
const exports = {};

module.exports = function collector(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  root.find(j.ExportNamedDeclaration).forEach(path => {
    exports[file.path] = exports[file.path] || [];
    // Collect export names
    path.node.specifiers?.forEach(spec => {
      exports[file.path].push(spec.exported.name);
    });
  });

  return undefined; // No changes, just collecting
};

module.exports.exports = exports; // Expose collected data
```

```javascript
// Second pass: use collected information
// transform.js
const collectedExports = require('./collect-exports').exports;

module.exports = function transformer(file, api, options) {
  const j = api.jscodeshift;
  const root = j(file.source);

  // Use cross-file data
  const availableExports = collectedExports[options.targetFile] || [];

  root.find(j.ImportDeclaration, { source: { value: options.targetFile } })
    .forEach(path => {
      // Filter to only valid exports
      path.node.specifiers = path.node.specifiers.filter(spec =>
        availableExports.includes(spec.imported.name)
      );
    });

  return root.toSource();
};
```

**Alternative (external state file):**

```bash
# Step 1: Collect data
jscodeshift -t collect-exports.js src/ --dry
node -e "require('./collect-exports'); console.log(JSON.stringify(exports))" > state.json

# Step 2: Transform using collected data
jscodeshift -t transform.js src/ --state-file=state.json
```

**Note:** For complex multi-file transforms, consider tools like codemod-cli that have built-in multi-pass support.

Reference: [jscodeshift - Options](https://github.com/facebook/jscodeshift#options)
