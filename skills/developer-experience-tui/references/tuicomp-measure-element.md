---
title: Use measureElement for Dynamic Sizing
impact: HIGH
impactDescription: enables responsive layouts based on content
tags: tuicomp, measure, dimensions, responsive, layout
---

## Use measureElement for Dynamic Sizing

Use `measureElement` to get computed dimensions of rendered components. This enables responsive layouts that adapt to content size and terminal dimensions.

**Incorrect (hardcoded dimensions):**

```typescript
function Table({ rows }: { rows: string[][] }) {
  return (
    <Box width={80} height={20}>
      {/* Hardcoded size may overflow or waste space */}
      {rows.map((row, i) => (
        <Text key={i}>{row.join(' | ')}</Text>
      ))}
    </Box>
  )
}
```

**Correct (measured dimensions):**

```typescript
import { measureElement, Box, Text } from 'ink'
import { useRef, useState, useEffect } from 'react'

function ResponsiveTable({ rows }: { rows: string[][] }) {
  const containerRef = useRef(null)
  const [width, setWidth] = useState(80)

  useEffect(() => {
    if (containerRef.current) {
      const { width: measuredWidth } = measureElement(containerRef.current)
      setWidth(measuredWidth)
    }
  }, [])

  const columnWidth = Math.floor(width / rows[0].length)

  return (
    <Box ref={containerRef} flexDirection="column" width="100%">
      {rows.map((row, i) => (
        <Box key={i}>
          {row.map((cell, j) => (
            <Box key={j} width={columnWidth}>
              <Text>{cell.slice(0, columnWidth - 1)}</Text>
            </Box>
          ))}
        </Box>
      ))}
    </Box>
  )
}
```

**Note:** `measureElement` returns accurate values only after initial render. Call it inside `useEffect` to ensure layout calculations are complete.

**When to use measureElement:**
- Responsive table column widths
- Text truncation based on available space
- Centering content in variable-size containers
- Adapting layout to terminal size changes

Reference: [Ink Documentation - measureElement](https://github.com/vadimdemedes/ink#measureelementref)
