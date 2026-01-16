---
title: Handle Process Signals Gracefully
impact: LOW-MEDIUM
impactDescription: enables clean shutdown and resource cleanup
tags: robust, signals, sigint, sigterm, cleanup
---

## Handle Process Signals Gracefully

Handle SIGINT (Ctrl+C) and SIGTERM for graceful shutdown. Clean up resources, restore terminal state, and exit with appropriate codes.

**Incorrect (no signal handling):**

```typescript
async function server() {
  const db = await connectDatabase()
  const server = await startServer()
  // Ctrl+C abruptly kills process
  // Database connection left hanging
  // Terminal may be in raw mode
}
```

**Correct (graceful signal handling):**

```typescript
async function server() {
  const db = await connectDatabase()
  const httpServer = await startServer()

  let isShuttingDown = false

  async function shutdown(signal: string) {
    if (isShuttingDown) return
    isShuttingDown = true

    console.log(`\n${signal} received, shutting down...`)

    // Stop accepting new connections
    httpServer.close()

    // Finish pending requests (with timeout)
    await Promise.race([
      waitForPendingRequests(),
      new Promise(resolve => setTimeout(resolve, 10000))
    ])

    // Clean up resources
    await db.close()

    console.log('Shutdown complete')
    process.exit(0)
  }

  process.on('SIGINT', () => shutdown('SIGINT'))
  process.on('SIGTERM', () => shutdown('SIGTERM'))
}
```

**With Ink applications:**

```typescript
import { render, useApp } from 'ink'

function App() {
  const { exit } = useApp()

  useEffect(() => {
    const handleSignal = () => {
      console.log('\nCleaning up...')
      exit()
    }

    process.on('SIGINT', handleSignal)
    process.on('SIGTERM', handleSignal)

    return () => {
      process.off('SIGINT', handleSignal)
      process.off('SIGTERM', handleSignal)
    }
  }, [exit])

  return <App />
}

async function main() {
  const { waitUntilExit } = render(<App />)
  await waitUntilExit()
  console.log('Cleanup complete')
}
```

**Immediate feedback on interrupt:**

```typescript
process.on('SIGINT', () => {
  // Give immediate feedback
  console.log('\nInterrupted, cleaning up...')

  // Then do cleanup with timeout
  const cleanup = async () => {
    await closeConnections()
    process.exit(130)  // 128 + signal number (2 for SIGINT)
  }

  // Force exit if cleanup takes too long
  setTimeout(() => process.exit(130), 5000)
  cleanup()
})
```

Reference: [clig.dev - Interactivity](https://clig.dev/#interactivity)
