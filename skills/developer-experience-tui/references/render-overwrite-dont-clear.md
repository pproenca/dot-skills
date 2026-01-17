---
title: Overwrite Content Instead of Clear and Redraw
impact: CRITICAL
impactDescription: eliminates blank frame flicker
tags: render, flicker, overwrite, animation, performance
---

## Overwrite Content Instead of Clear and Redraw

Overwrite terminal content in place rather than clearing the screen first. Clearing creates a brief blank frame that users perceive as flicker.

**Incorrect (clear then draw causes blank frame):**

```typescript
function updateProgress(percent: number) {
  console.clear()  // Creates visible blank frame
  console.log(`Progress: ${percent}%`)
  console.log(renderProgressBar(percent))
}
```

**Correct (overwrite in place):**

```typescript
function updateProgress(percent: number) {
  // Move cursor to start without clearing
  process.stdout.write('\x1b[H')
  process.stdout.write(`Progress: ${percent}%\x1b[K\n`)  // \x1b[K clears to end of line
  process.stdout.write(`${renderProgressBar(percent)}\x1b[K`)
}
```

**With Ink (automatic):**

```tsx
function ProgressDisplay({ percent }: { percent: number }) {
  // Ink handles overwrites automatically - no flicker
  return (
    <Box flexDirection="column">
      <Text>Progress: {percent}%</Text>
      <ProgressBar percent={percent} />
    </Box>
  )
}
```

Reference: [Textualize Blog - 7 Things Building a TUI Framework](https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/)
