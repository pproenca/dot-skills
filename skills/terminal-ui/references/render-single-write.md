---
title: Batch Terminal Output in Single Write
impact: CRITICAL
impactDescription: eliminates partial frame flicker
tags: render, flicker, batching, stdout, performance
---

## Batch Terminal Output in Single Write

Write new content to stdout in a single operation. Multiple sequential writes risk partial updates becoming visible, causing visual flicker.

**Incorrect (multiple writes cause flicker):**

```typescript
// Each write may render before the next one
process.stdout.write('\x1b[2J')     // Clear screen
process.stdout.write('\x1b[H')      // Move cursor
process.stdout.write('Loading...')  // Content
process.stdout.write('\n')          // Newline
// User may see blank frame between clear and content
```

**Correct (single batched write):**

```typescript
const output = [
  '\x1b[2J',     // Clear screen
  '\x1b[H',      // Move cursor
  'Loading...',  // Content
  '\n'           // Newline
].join('')

process.stdout.write(output)
// All content appears atomically
```

**Note:** Ink handles this automatically through its React reconciler. When building custom renderers or using raw escape codes, always batch writes.

Reference: [Textualize Blog - 7 Things Building a TUI Framework](https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/)
