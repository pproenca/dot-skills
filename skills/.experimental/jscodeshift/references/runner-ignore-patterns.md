---
title: Use Ignore Patterns to Skip Non-Source Files
impact: LOW-MEDIUM
impactDescription: prevents wasted processing on generated/vendor code
tags: runner, ignore, patterns, filtering
---

## Use Ignore Patterns to Skip Non-Source Files

Running transforms on node_modules, build output, or generated files wastes time and may cause unexpected changes. Use ignore patterns.

**Incorrect (processes everything):**

```bash
# Processes node_modules, dist, etc.
jscodeshift -t transform.js .

# May take 10× longer and produce unwanted changes
```

**Correct (ignore non-source directories):**

```bash
# Use --ignore-pattern flag
jscodeshift \
  --ignore-pattern="**/node_modules/**" \
  --ignore-pattern="**/dist/**" \
  --ignore-pattern="**/build/**" \
  --ignore-pattern="**/*.min.js" \
  -t transform.js src/
```

**Alternative (use gitignore):**

```bash
# Automatically ignores everything in .gitignore
jscodeshift --gitignore -t transform.js .

# Combines with additional patterns
jscodeshift --gitignore --ignore-pattern="**/__mocks__/**" -t transform.js .
```

**Common patterns to ignore:**

| Pattern | Purpose |
|---------|---------|
| `**/node_modules/**` | Dependencies |
| `**/dist/**` | Build output |
| `**/build/**` | Build output |
| `**/*.min.js` | Minified files |
| `**/*.bundle.js` | Bundled files |
| `**/vendor/**` | Third-party code |
| `**/__generated__/**` | Generated code |
| `**/coverage/**` | Test coverage |

**Note:** Always use `--gitignore` as a baseline, then add project-specific patterns.

Reference: [jscodeshift - Ignore Patterns](https://github.com/facebook/jscodeshift#usage-cli)
