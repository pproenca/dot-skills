---
title: Virtualize Large Lists and Tables
impact: MEDIUM-HIGH
impactDescription: 10-100× rendering performance for large lists
tags: data, virtualization, tanstack-virtual, performance, lists
---

## Virtualize Large Lists and Tables

For lists or tables with 100+ items, use virtualization to render only visible rows. Rendering all rows causes memory bloat and janky scrolling.

**Incorrect (rendering all rows):**

```tsx
function LogViewer({ logs }: { logs: LogEntry[] }) {
  return (
    <div className="h-[600px] overflow-auto">
      {logs.map((log) => (
        <div key={log.id} className="p-2 border-b">
          {/* Renders 10,000 DOM nodes for 10,000 logs */}
          <span className="text-muted-foreground">{log.timestamp}</span>
          <span className="ml-2">{log.message}</span>
        </div>
      ))}
    </div>
  )
}
```

**Correct (virtualized with TanStack Virtual):**

```tsx
import { useVirtualizer } from "@tanstack/react-virtual"

function LogViewer({ logs }: { logs: LogEntry[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: logs.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 40, // Estimated row height in pixels
    overscan: 5, // Render 5 extra rows above/below viewport
  })

  return (
    <div ref={parentRef} className="h-[600px] overflow-auto">
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          position: "relative",
        }}
      >
        {virtualizer.getVirtualItems().map((virtualRow) => {
          const log = logs[virtualRow.index]
          return (
            <div
              key={virtualRow.key}
              className="absolute w-full p-2 border-b"
              style={{
                height: `${virtualRow.size}px`,
                transform: `translateY(${virtualRow.start}px)`,
              }}
            >
              {/* Only ~20 DOM nodes rendered at any time */}
              <span className="text-muted-foreground">{log.timestamp}</span>
              <span className="ml-2">{log.message}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}
```

**When to virtualize:**
- Lists with 100+ items
- Tables with 50+ rows and complex cells
- Log viewers, chat histories, infinite scroll
- Any scrollable list causing jank

Reference: [TanStack Virtual](https://tanstack.com/virtual/latest)
