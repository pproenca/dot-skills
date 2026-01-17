---
title: Provide Sensible Defaults for All Options
impact: MEDIUM
impactDescription: reduces friction for common use cases
tags: tuicfg, defaults, options, ux, cli
---

## Provide Sensible Defaults for All Options

Every configurable option should have a sensible default. Users should be able to run commands without specifying anything for the common case.

**Incorrect (requires explicit configuration):**

```typescript
const config = await p.group({
  port: () => p.text({
    message: 'Port number?',
    validate: (v) => !v ? 'Port is required' : undefined
  }),
  host: () => p.text({
    message: 'Host?',
    validate: (v) => !v ? 'Host is required' : undefined
  }),
  timeout: () => p.text({
    message: 'Timeout (ms)?',
    validate: (v) => !v ? 'Timeout is required' : undefined
  })
})
// User must answer 3 questions for basic usage
```

**Correct (smart defaults):**

```typescript
const config = await p.group({
  port: () => p.text({
    message: 'Port number?',
    placeholder: '3000',
    defaultValue: '3000'
  }),
  host: () => p.text({
    message: 'Host?',
    placeholder: 'localhost',
    defaultValue: 'localhost'
  }),
  timeout: () => p.text({
    message: 'Timeout (ms)?',
    placeholder: '5000',
    defaultValue: '5000'
  })
})
// User can press Enter through all prompts for sensible defaults
```

**CLI flag defaults:**

```typescript
import { parseArgs } from 'util'

const { values } = parseArgs({
  options: {
    port: { type: 'string', short: 'p', default: '3000' },
    host: { type: 'string', short: 'h', default: 'localhost' },
    verbose: { type: 'boolean', short: 'v', default: false },
    config: { type: 'string', short: 'c', default: './config.json' }
  }
})

// mycli serve          -> uses all defaults
// mycli serve -p 8080  -> overrides just port
```

**Environment-aware defaults:**

```typescript
const defaults = {
  port: process.env.PORT || '3000',
  host: process.env.HOST || 'localhost',
  logLevel: process.env.DEBUG ? 'debug' : 'info',
  output: process.env.CI ? 'json' : 'pretty'
}
```

Reference: [clig.dev - Arguments and flags](https://clig.dev/#arguments-and-flags)
