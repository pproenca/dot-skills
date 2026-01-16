---
title: Use useInput Hook for Keyboard Handling
impact: CRITICAL
impactDescription: prevents raw stdin complexity
tags: input, useinput, keyboard, ink, hooks
---

## Use useInput Hook for Keyboard Handling

Use Ink's `useInput` hook instead of manually handling stdin. It provides parsed key events with modifier detection and proper cleanup.

**Incorrect (manual stdin handling):**

```typescript
import { render, Box, Text } from 'ink'
import { useEffect } from 'react'

function App() {
  useEffect(() => {
    process.stdin.setRawMode(true)
    process.stdin.resume()

    const handler = (data: Buffer) => {
      const key = data.toString()
      if (key === '\x03') process.exit()  // Ctrl+C
      if (key === 'q') process.exit()
      // Complex parsing for arrows, modifiers...
    }

    process.stdin.on('data', handler)
    return () => process.stdin.off('data', handler)
    // Error-prone, no modifier detection
  }, [])

  return <Text>Press q to quit</Text>
}
```

**Correct (useInput hook):**

```typescript
import { render, useInput, useApp, Box, Text } from 'ink'

function App() {
  const { exit } = useApp()

  useInput((input, key) => {
    if (input === 'q') exit()
    if (key.escape) exit()
    if (key.leftArrow) handleLeft()
    if (key.return) handleSubmit()
    if (key.ctrl && input === 'c') exit()
  })

  return <Text>Press q or Escape to quit</Text>
}
```

**Benefits:**
- Automatic raw mode management
- Parsed modifier keys (ctrl, meta, shift)
- Arrow keys and special keys detected
- Proper cleanup on unmount

Reference: [Ink Documentation - useInput](https://github.com/vadimdemedes/ink#useinputinputhandler-options)
