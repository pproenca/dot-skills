---
title: Configure toSource() for Consistent Formatting
impact: MEDIUM
impactDescription: prevents unnecessary diffs and maintains code style
tags: codegen, toSource, formatting, options
---

## Configure toSource() for Consistent Formatting

The `toSource()` method accepts options that control output formatting. Default options may produce inconsistent style with existing code.

**Incorrect (default options create inconsistent style):**

```javascript
// Default toSource() uses its own formatting preferences
return root.toSource();

// Original: const x = {a: 1, b: 2}
// Output may become:
// const x = {
//   a: 1,
//   b: 2
// }
```

**Correct (explicit formatting options):**

```javascript
// Match project's code style
return root.toSource({
  quote: 'single',           // Use single quotes
  trailingComma: true,       // Add trailing commas
  tabWidth: 2,               // 2-space indentation
  useTabs: false,            // Spaces not tabs
  lineTerminator: '\n'       // Unix line endings
});
```

**Common options:**

| Option | Values | Effect |
|--------|--------|--------|
| `quote` | `'single'`, `'double'`, `'auto'` | String quote style |
| `trailingComma` | `true`, `false` | Trailing commas in arrays/objects |
| `tabWidth` | `2`, `4`, etc. | Indentation width |
| `useTabs` | `true`, `false` | Tabs vs spaces |
| `lineTerminator` | `'\n'`, `'\r\n'` | Line ending style |
| `wrapColumn` | number | Max line width for wrapping |

**Alternative (project-level config):**

```javascript
// Create shared config
const printOptions = {
  quote: 'single',
  trailingComma: true,
  tabWidth: 2
};

// Use in all transforms
module.exports = function transformer(file, api) {
  // ... transformation
  return root.toSource(printOptions);
};
```

Reference: [recast - Printing Options](https://github.com/benjamn/recast#source-maps)
