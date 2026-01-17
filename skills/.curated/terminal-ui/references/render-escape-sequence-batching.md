---
title: Defer ANSI Escape Code Generation to Final Output
impact: HIGH
impactDescription: reduces intermediate string allocations
tags: render, ansi, escape-codes, performance, optimization
---

## Defer ANSI Escape Code Generation to Final Output

Build content using semantic representations (segments with styles) and convert to ANSI escape codes only at the final output stage.

**Incorrect (escape codes generated inline):**

```typescript
function formatLine(text: string, isError: boolean): string {
  if (isError) {
    return `\x1b[31m${text}\x1b[0m`  // Red + reset
  }
  return `\x1b[32m${text}\x1b[0m`  // Green + reset
}

function render(lines: string[]) {
  // Each line already has escape codes - hard to optimize
  return lines.map(line => formatLine(line, line.startsWith('ERR'))).join('\n')
}
```

**Correct (semantic segments, late conversion):**

```typescript
interface Segment {
  text: string
  style: 'error' | 'success' | 'default'
}

function buildSegments(lines: string[]): Segment[] {
  return lines.map(line => ({
    text: line,
    style: line.startsWith('ERR') ? 'error' : 'success'
  }))
}

function toAnsi(segments: Segment[]): string {
  const styles = { error: '\x1b[31m', success: '\x1b[32m', default: '' }

  return segments
    .map(seg => `${styles[seg.style]}${seg.text}\x1b[0m`)
    .join('\n')
}

// Build semantic model, convert at final output
const segments = buildSegments(lines)
process.stdout.write(toAnsi(segments))
```

**Benefits:**
- Semantic model enables optimizations like combining adjacent same-style segments
- Easier to implement partial updates by comparing segment arrays
- Style changes don't require string manipulation

Reference: [Textualize Blog - Algorithms for High Performance Terminal Apps](https://textual.textualize.io/blog/2024/12/12/algorithms-for-high-performance-terminal-apps/)
