---
title: Detect TTY and Adjust Behavior Accordingly
impact: LOW-MEDIUM
impactDescription: prevents 100% of CI hangs from interactive prompts
tags: robust, tty, detection, ci, automation
---

## Detect TTY and Adjust Behavior Accordingly

Check if stdin/stdout are TTYs and adjust behavior. Disable interactive features, colors, and animations when piped or in non-interactive environments.

**Incorrect (assumes interactive terminal):**

```typescript
import * as p from '@clack/prompts'

async function main() {
  const name = await p.text({ message: 'Name?' })
  // Hangs in CI waiting for input that never comes
}
```

**Correct (TTY-aware):**

```typescript
import * as p from '@clack/prompts'

async function main() {
  // Check for interactive terminal
  const isInteractive = process.stdin.isTTY && process.stdout.isTTY

  if (!isInteractive) {
    // Non-interactive: require flags
    if (!args.name) {
      console.error('Error: --name is required in non-interactive mode')
      process.exit(1)
    }
    return { name: args.name }
  }

  // Interactive: use prompts
  const name = await p.text({ message: 'Name?' })
  return { name }
}
```

**Comprehensive detection:**

```typescript
interface Environment {
  isTTY: boolean
  isCI: boolean
  hasColor: boolean
  termWidth: number
}

function detectEnvironment(): Environment {
  const isTTY = Boolean(process.stdout.isTTY)

  const isCI = Boolean(
    process.env.CI ||
    process.env.CONTINUOUS_INTEGRATION ||
    process.env.GITHUB_ACTIONS ||
    process.env.GITLAB_CI ||
    process.env.JENKINS_URL
  )

  const hasColor = isTTY &&
    !process.env.NO_COLOR &&
    process.env.TERM !== 'dumb' &&
    process.env.FORCE_COLOR !== '0'

  const termWidth = isTTY
    ? process.stdout.columns || 80
    : 80

  return { isTTY, isCI, hasColor, termWidth }
}

const env = detectEnvironment()

if (env.isCI) {
  // Longer timeouts
  // Simpler output format
  // No animations
}
```

**Adjust output for non-TTY:**

```typescript
function log(message: string) {
  if (process.stdout.isTTY) {
    console.log(color.cyan(`ℹ ${message}`))
  } else {
    console.log(`[INFO] ${message}`)  // Plain text for logs
  }
}
```

Reference: [clig.dev - Output](https://clig.dev/#output)
