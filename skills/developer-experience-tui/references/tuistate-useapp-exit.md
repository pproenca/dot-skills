---
title: Use useApp Hook for Application Lifecycle
impact: HIGH
impactDescription: prevents terminal state corruption on exit
tags: tuistate, useapp, exit, lifecycle, cleanup
---

## Use useApp Hook for Application Lifecycle

Use the `useApp` hook to access application-level controls like `exit()`. This ensures proper unmounting, cleanup, and exit code handling.

**Incorrect (process.exit without cleanup):**

```typescript
function App() {
  useInput((input) => {
    if (input === 'q') {
      process.exit(0)  // Abrupt exit, no cleanup
    }
  })

  return <Text>Press q to quit</Text>
}
// Terminal may be left in raw mode
// Pending operations may be orphaned
```

**Correct (useApp exit):**

```typescript
import { render, useApp, useInput, Text } from 'ink'

function App() {
  const { exit } = useApp()

  useInput((input) => {
    if (input === 'q') {
      exit()  // Proper cleanup and unmounting
    }
  })

  return <Text>Press q to quit</Text>
}

async function main() {
  const { waitUntilExit } = render(<App />)

  await waitUntilExit()
  console.log('Cleanup complete')
}
```

**Exiting with error:**

```typescript
function App() {
  const { exit } = useApp()

  async function runTask() {
    try {
      await dangerousOperation()
      exit()  // Success exit
    } catch (error) {
      exit(error as Error)  // Exit with error - waitUntilExit rejects
    }
  }

  // ...
}

async function main() {
  try {
    const { waitUntilExit } = render(<App />)
    await waitUntilExit()
  } catch (error) {
    console.error('App failed:', error)
    process.exit(1)
  }
}
```

**Benefits:**
- Terminal state is properly restored
- React cleanup functions are called
- Exit code can be controlled
- Async operations can complete before exit

Reference: [Ink Documentation - useApp](https://github.com/vadimdemedes/ink#useapp)
