---
title: Always Restore Terminal State on Exit
impact: LOW-MEDIUM
impactDescription: prevents broken terminal after crashes
tags: robust, terminal, restore, cleanup, raw-mode
---

## Always Restore Terminal State on Exit

Restore terminal settings (cursor visibility, raw mode, alternate screen) before exit. A broken terminal state after a crash is a poor user experience.

**Incorrect (no state restoration):**

```typescript
async function interactiveMode() {
  // Enter raw mode for key handling
  process.stdin.setRawMode(true)
  process.stdin.resume()

  // Hide cursor
  process.stdout.write('\x1b[?25l')

  await runInteractiveSession()

  // If crash happens, terminal is left in bad state
  // Cursor invisible, raw mode on, input broken
}
```

**Correct (guaranteed restoration):**

```typescript
async function interactiveMode() {
  const originalRawMode = process.stdin.isRaw

  // Setup terminal
  process.stdin.setRawMode(true)
  process.stdin.resume()
  process.stdout.write('\x1b[?25l')  // Hide cursor

  function restore() {
    process.stdout.write('\x1b[?25h')  // Show cursor
    process.stdin.setRawMode(originalRawMode ?? false)
    process.stdin.pause()
  }

  // Restore on normal exit
  process.on('exit', restore)

  // Restore on signals
  process.on('SIGINT', () => {
    restore()
    process.exit(130)
  })

  try {
    await runInteractiveSession()
  } finally {
    restore()
  }
}
```

**With Ink (automatic):**

```typescript
import { render } from 'ink'

async function main() {
  // Ink handles terminal state automatically
  const { waitUntilExit } = render(<App />)

  await waitUntilExit()
  // Terminal state is restored automatically
}
```

**Alternate screen buffer:**

```typescript
const ALTERNATE_SCREEN_ON = '\x1b[?1049h'
const ALTERNATE_SCREEN_OFF = '\x1b[?1049l'

async function fullscreenApp() {
  process.stdout.write(ALTERNATE_SCREEN_ON)

  const cleanup = () => {
    process.stdout.write(ALTERNATE_SCREEN_OFF)
  }

  process.on('exit', cleanup)
  process.on('SIGINT', () => {
    cleanup()
    process.exit(130)
  })
  process.on('uncaughtException', (error) => {
    cleanup()
    console.error(error)
    process.exit(1)
  })

  try {
    await runApp()
  } finally {
    cleanup()
  }
}
```

Reference: [Ink Documentation - render](https://github.com/vadimdemedes/ink#rendernode)
