---
title: Use Static Component for Log Output
impact: HIGH
impactDescription: prevents log lines from re-rendering
tags: tuicomp, static, logs, output, scrollback
---

## Use Static Component for Log Output

Use the `Static` component for content that should be written once and never re-rendered, like log lines or command output. This preserves terminal scrollback and reduces CPU usage.

**Incorrect (logs in regular component):**

```typescript
function Logger({ logs }: { logs: string[] }) {
  return (
    <Box flexDirection="column">
      {logs.map((log, i) => (
        <Text key={i}>{log}</Text>
      ))}
    </Box>
  )
  // All logs re-render when new log is added
  // Previous logs may flicker or disappear from scrollback
}
```

**Correct (Static for permanent output):**

```typescript
import { Static, Box, Text } from 'ink'

function Logger({ logs }: { logs: string[] }) {
  return (
    <Box flexDirection="column">
      <Static items={logs}>
        {(log, index) => (
          <Text key={index}>{log}</Text>
        )}
      </Static>
    </Box>
  )
  // Each log is rendered once and never re-rendered
  // Properly preserved in terminal scrollback
}
```

**Combined with dynamic content:**

```typescript
function BuildOutput({
  logs,
  currentStep,
  isComplete
}: {
  logs: string[]
  currentStep: string
  isComplete: boolean
}) {
  return (
    <Box flexDirection="column">
      {/* Static logs - written once, preserved in scrollback */}
      <Static items={logs}>
        {(log, index) => <Text key={index}>{log}</Text>}
      </Static>

      {/* Dynamic status - re-renders on each update */}
      {!isComplete && (
        <Box marginTop={1}>
          <Text color="cyan">
            <Spinner /> {currentStep}
          </Text>
        </Box>
      )}
    </Box>
  )
}
```

Reference: [Ink Documentation - Static](https://github.com/vadimdemedes/ink#static)
