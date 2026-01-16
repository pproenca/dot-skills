---
title: Always Provide Escape Routes
impact: CRITICAL
impactDescription: prevents user frustration and stuck states
tags: input, escape, ctrl-c, exit, ux
---

## Always Provide Escape Routes

Ensure users can always exit or cancel operations. Handle Ctrl+C, Escape, and 'q' consistently. Never trap users in states they can't exit.

**Incorrect (no clear exit path):**

```typescript
function ConfirmDialog({ message }: { message: string }) {
  const [answer, setAnswer] = useState<boolean | null>(null)

  useInput((input) => {
    if (input === 'y') setAnswer(true)
    if (input === 'n') setAnswer(false)
    // No escape route - user stuck if they don't want either option
  })

  return <Text>{message} (y/n)</Text>
}
```

**Correct (multiple escape routes):**

```typescript
function ConfirmDialog({
  message,
  onConfirm,
  onCancel
}: {
  message: string
  onConfirm: () => void
  onCancel: () => void
}) {
  const { exit } = useApp()

  useInput((input, key) => {
    if (input === 'y' || input === 'Y') {
      onConfirm()
      return
    }

    if (input === 'n' || input === 'N') {
      onCancel()
      return
    }

    // Multiple escape routes
    if (key.escape || input === 'q' || (key.ctrl && input === 'c')) {
      onCancel()
      return
    }
  })

  return (
    <Box flexDirection="column">
      <Text>{message}</Text>
      <Text dimColor>y/n (or press Escape to cancel)</Text>
    </Box>
  )
}
```

**With Clack prompts:**

```typescript
import * as p from '@clack/prompts'

const result = await p.confirm({ message: 'Continue?' })

if (p.isCancel(result)) {
  p.cancel('Operation cancelled.')
  process.exit(0)  // Clean exit
}
```

**Benefits:**
- Users never feel trapped
- Consistent cancellation behavior across the application
- Clear indication of how to exit

Reference: [clig.dev - Interactivity](https://clig.dev/#interactivity)
