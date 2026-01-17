---
title: Prefer Flags Over Positional Arguments
impact: MEDIUM
impactDescription: reduces user errors by 50% through self-documentation
tags: tuicfg, flags, arguments, cli, parsing
---

## Prefer Flags Over Positional Arguments

Use named flags instead of positional arguments for most options. Flags are self-documenting, order-independent, and easier to extend.

**Incorrect (positional arguments):**

```bash
# What do these arguments mean?
mycli deploy prod main true 5
```

```typescript
const [environment, branch, force, retries] = process.argv.slice(2)
// Fragile, hard to remember order, no self-documentation
```

**Correct (named flags):**

```bash
# Self-documenting, any order
mycli deploy --env prod --branch main --force --retries 5
mycli deploy --retries 5 --env prod --force --branch main
```

```typescript
import { parseArgs } from 'util'

const { values } = parseArgs({
  options: {
    env: { type: 'string', short: 'e', default: 'staging' },
    branch: { type: 'string', short: 'b', default: 'main' },
    force: { type: 'boolean', short: 'f', default: false },
    retries: { type: 'string', short: 'r', default: '3' }
  }
})

const { env, branch, force, retries } = values
```

**When positional arguments ARE appropriate:**

```typescript
// Primary target of the command (like file paths)
// mycli compile src/main.ts
// mycli run script.js

const { positionals } = parseArgs({
  allowPositionals: true,
  options: {
    output: { type: 'string', short: 'o' },
    watch: { type: 'boolean', short: 'w' }
  }
})

const inputFile = positionals[0]  // Primary target
```

**Standard flag conventions:**

```typescript
const { values } = parseArgs({
  options: {
    help: { type: 'boolean', short: 'h' },      // -h, --help
    version: { type: 'boolean', short: 'v' },   // -v, --version
    verbose: { type: 'boolean', short: 'V' },   // -V, --verbose
    quiet: { type: 'boolean', short: 'q' },     // -q, --quiet
    force: { type: 'boolean', short: 'f' },     // -f, --force
    output: { type: 'string', short: 'o' },     // -o, --output
    config: { type: 'string', short: 'c' }      // -c, --config
  }
})
```

Reference: [clig.dev - Arguments and flags](https://clig.dev/#arguments-and-flags)
