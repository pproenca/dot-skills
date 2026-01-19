---
title: Use Verbose Output for Debugging Transforms
impact: LOW-MEDIUM
impactDescription: reduces debugging time by 50-80%
tags: runner, verbose, debugging, logging
---

## Use Verbose Output for Debugging Transforms

When transforms don't behave as expected, verbose output helps identify which files are processed and what changes are made.

**Incorrect (silent failures):**

```bash
# No output except final summary
jscodeshift -t transform.js src/

# Results:
# 0 errors
# 47 unmodified
# 0 ok
# Hard to debug why nothing changed
```

**Correct (verbose and print output):**

```bash
# Show each file being processed
jscodeshift --verbose=2 -t transform.js src/

# Output:
# Processing src/utils.ts
# Processing src/hooks.ts
# ...

# Also print transformed source to stdout
jscodeshift --dry --print -t transform.js src/

# Shows what changes WOULD be made without writing
```

**Verbose levels:**

| Level | Output |
|-------|--------|
| `0` | Silent (errors only) |
| `1` | Summary (default) |
| `2` | File names as processed |

**Combining flags for debugging:**

```bash
# Full debugging output
jscodeshift \
  --verbose=2 \    # Show files
  --dry \          # Don't write changes
  --print \        # Show transformed output
  --cpus=1 \       # Single-threaded for ordered output
  -t transform.js src/file.ts
```

**Using console.log in transforms:**

```javascript
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  console.log(`Processing: ${file.path}`);

  const root = j(file.source);
  const matches = root.find(j.CallExpression, { callee: { name: 'target' } });

  console.log(`Found ${matches.size()} matches`);

  // Transform logic...
};
```

Reference: [jscodeshift CLI - Verbose](https://github.com/facebook/jscodeshift#usage-cli)
