---
title: Use Spinner and Tasks for Long Operations
impact: MEDIUM-HIGH
impactDescription: prevents perceived hang during async work
tags: prompt, spinner, tasks, async, progress
---

## Use Spinner and Tasks for Long Operations

Show spinners or progress tasks for operations longer than 1 second. Users need visual feedback that work is happening.

**Incorrect (silent waiting):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

await installDependencies()  // User sees nothing for 30+ seconds
await runBuild()
await runTests()

p.outro('Done!')
// User thinks CLI is frozen
```

**Correct (spinner for single operation):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

const s = p.spinner()

s.start('Installing dependencies')
await installDependencies()
s.stop('Dependencies installed')

s.start('Building project')
await runBuild()
s.stop('Build complete')

p.outro('Done!')
```

**Correct (tasks for multiple operations):**

```typescript
import * as p from '@clack/prompts'

p.intro('Setting up project')

await p.tasks([
  {
    title: 'Installing dependencies',
    task: async (message) => {
      message('Resolving packages...')
      await resolveDeps()
      message('Downloading...')
      await downloadDeps()
      return 'Installed 142 packages'
    }
  },
  {
    title: 'Building project',
    task: async () => {
      await runBuild()
      return 'Built in 2.3s'
    }
  },
  {
    title: 'Running tests',
    task: async () => {
      const result = await runTests()
      return `${result.passed} passed, ${result.failed} failed`
    },
    enabled: process.env.SKIP_TESTS !== 'true'
  }
])

p.outro('Setup complete!')
```

**Benefits:**
- Visual indication of progress
- Dynamic status messages during long operations
- Conditional task execution with `enabled`
- Success/failure messages per task

Reference: [Clack Documentation - spinner, tasks](https://github.com/bombshell-dev/clack)
