---
title: Handle Cancellation Gracefully with isCancel
impact: MEDIUM-HIGH
impactDescription: prevents crashes and ensures clean exit
tags: prompt, cancel, iscancel, clack, exit
---

## Handle Cancellation Gracefully with isCancel

Always check for cancellation using `isCancel()` after prompts. Cancelled prompts return a symbol, not the expected value type.

**Incorrect (no cancellation check):**

```typescript
import * as p from '@clack/prompts'

const name = await p.text({ message: 'Name?' })
const uppercased = name.toUpperCase()  // Crashes if cancelled!
// TypeError: Cannot read property 'toUpperCase' of Symbol
```

**Correct (cancellation check):**

```typescript
import * as p from '@clack/prompts'

const name = await p.text({ message: 'Name?' })

if (p.isCancel(name)) {
  p.cancel('Operation cancelled.')
  process.exit(0)
}

// TypeScript now knows name is string, not Symbol
const uppercased = name.toUpperCase()
```

**In grouped prompts:**

```typescript
const config = await p.group({
  name: () => p.text({ message: 'Name?' }),
  type: () => p.select({
    message: 'Type?',
    options: [{ value: 'ts', label: 'TypeScript' }]
  })
}, {
  onCancel: () => {
    p.cancel('Setup cancelled.')
    process.exit(0)
  }
})
// No need for individual isCancel checks
```

**Partial completion handling:**

```typescript
async function setupWithRecovery() {
  const name = await p.text({ message: 'Name?' })
  if (p.isCancel(name)) {
    return { cancelled: true, step: 'name' }
  }

  const type = await p.select({
    message: 'Type?',
    options: [{ value: 'ts', label: 'TypeScript' }]
  })
  if (p.isCancel(type)) {
    // Could offer to save partial progress
    p.log.info(`Saved name: ${name}`)
    return { cancelled: true, step: 'type', partial: { name } }
  }

  return { cancelled: false, config: { name, type } }
}
```

Reference: [Clack Documentation - isCancel](https://github.com/bombshell-dev/clack)
