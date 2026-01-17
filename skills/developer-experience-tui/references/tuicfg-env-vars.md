---
title: Support Standard Environment Variables
impact: MEDIUM
impactDescription: enables scripting and CI integration
tags: tuicfg, environment, variables, ci, automation
---

## Support Standard Environment Variables

Respect common environment variables like `NO_COLOR`, `DEBUG`, `CI`, and tool-specific prefixes. This enables automation and accessibility.

**Incorrect (ignores standard variables):**

```typescript
import color from 'picocolors'

function log(message: string) {
  // Always uses colors, ignores NO_COLOR
  console.log(color.cyan(`ℹ ${message}`))
}

async function runPrompts() {
  // Always prompts, even in CI where stdin isn't interactive
  const name = await p.text({ message: 'Name?' })
  return name
}
// Breaks in CI, ignores accessibility preferences
```

**Correct (respects standard variables):**

```typescript
import color from 'picocolors'

// Respect NO_COLOR and TERM
const useColor = process.stdout.isTTY &&
  !process.env.NO_COLOR &&
  process.env.TERM !== 'dumb' &&
  process.env.FORCE_COLOR !== '0'

// Detect CI environments
const isCI = Boolean(
  process.env.CI ||
  process.env.CONTINUOUS_INTEGRATION ||
  process.env.GITHUB_ACTIONS ||
  process.env.GITLAB_CI
)

function log(message: string) {
  if (useColor) {
    console.log(color.cyan(`ℹ ${message}`))
  } else {
    console.log(`[INFO] ${message}`)
  }
}

async function runPrompts(cliArgs: { name?: string }) {
  // In CI, require flags instead of interactive prompts
  if (isCI && !cliArgs.name) {
    console.error('Error: --name required in CI environment')
    process.exit(1)
  }

  if (cliArgs.name) return cliArgs.name

  const name = await p.text({ message: 'Name?' })
  return name
}
```

**Tool-specific prefix pattern:**

```typescript
// Use MYAPP_ prefix for tool-specific config
const config = {
  apiKey: process.env.MYAPP_API_KEY,
  baseUrl: process.env.MYAPP_BASE_URL || 'https://api.example.com',
  timeout: parseInt(process.env.MYAPP_TIMEOUT || '5000', 10),
  logLevel: process.env.MYAPP_LOG_LEVEL || 'info'
}
```

Reference: [clig.dev - Environment variables](https://clig.dev/#environment-variables)
