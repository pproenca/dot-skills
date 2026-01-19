---
title: Filter Files by Extension
impact: LOW-MEDIUM
impactDescription: prevents 100% of missed file type transforms
tags: runner, extensions, filtering, file-types
---

## Filter Files by Extension

By default, jscodeshift processes `.js` files. Specify extensions to include TypeScript, JSX, or exclude test files.

**Incorrect (misses TypeScript files):**

```bash
# Only processes .js files by default
jscodeshift -t transform.js src/

# Misses: src/utils.ts, src/Component.tsx
```

**Correct (explicit extensions):**

```bash
# Include TypeScript and JSX
jscodeshift --extensions=js,jsx,ts,tsx -t transform.js src/

# TypeScript only
jscodeshift --extensions=ts,tsx -t transform.js src/

# JavaScript without JSX
jscodeshift --extensions=js -t transform.js src/
```

**Combining with parser:**

```bash
# Must specify both extensions and parser for TypeScript
jscodeshift \
  --extensions=ts,tsx \
  --parser=tsx \
  -t transform.js src/
```

**Alternative (glob patterns for fine control):**

```bash
# Only component files
jscodeshift -t transform.js "src/components/**/*.tsx"

# Exclude test files
jscodeshift -t transform.js "src/**/!(*.test|*.spec).ts"

# Multiple specific paths
jscodeshift -t transform.js src/utils src/hooks src/components
```

**Extension vs parser mismatch:**

```bash
# WRONG: tsx parser can't parse .js files with Flow
jscodeshift --extensions=js --parser=tsx -t transform.js src/

# RIGHT: Match parser to file type
jscodeshift --extensions=ts,tsx --parser=tsx -t transform.js src/
jscodeshift --extensions=js --parser=babel -t transform.js src/
```

Reference: [jscodeshift CLI - Extensions](https://github.com/facebook/jscodeshift#usage-cli)
