---
title: Dynamic Import Heavy Components
impact: LOW-MEDIUM
impactDescription: reduces initial bundle by 20-50% for code-editor, charts, date-pickers
tags: perf, dynamic-import, code-splitting, bundle-size, lazy
---

## Dynamic Import Heavy Components

Use dynamic imports for heavy shadcn/ui components like Calendar, Chart, or Command. These components add significant bundle weight even when not rendered.

**Incorrect (static import always loaded):**

```tsx
import { Calendar } from "@/components/ui/calendar"
import { Command } from "@/components/ui/command"

function SettingsPage() {
  const [showDatePicker, setShowDatePicker] = useState(false)

  return (
    <div>
      {showDatePicker && <Calendar />}
      {/* Calendar code loaded even if never shown */}
    </div>
  )
}
```

**Correct (dynamic import when needed):**

```tsx
import dynamic from "next/dynamic"
import { Skeleton } from "@/components/ui/skeleton"

const Calendar = dynamic(
  () => import("@/components/ui/calendar").then((mod) => mod.Calendar),
  {
    loading: () => <Skeleton className="h-[300px] w-[280px]" />,
    ssr: false,  // Calendar uses browser APIs
  }
)

const Command = dynamic(
  () => import("@/components/ui/command").then((mod) => mod.Command),
  { ssr: false }
)

function SettingsPage() {
  const [showDatePicker, setShowDatePicker] = useState(false)

  return (
    <div>
      {showDatePicker && <Calendar />}
      {/* Calendar code only loaded when showDatePicker is true */}
    </div>
  )
}
```

**Components worth lazy-loading:**
| Component | Typical Bundle Impact |
|-----------|----------------------|
| Calendar (react-day-picker) | ~30KB |
| Command (cmdk) | ~15KB |
| Charts (recharts) | ~100KB+ |
| Data Table (tanstack-table) | ~40KB |

Reference: [Next.js Dynamic Imports](https://nextjs.org/docs/pages/building-your-application/optimizing/lazy-loading)
