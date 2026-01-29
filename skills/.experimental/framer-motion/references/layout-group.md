---
title: Group Related Layout Animations with LayoutGroup
impact: HIGH
impactDescription: batches measurements, prevents layout shift between components
tags: layout, LayoutGroup, coordination, batch
---

## Group Related Layout Animations with LayoutGroup

When multiple components have layout animations that should coordinate, wrap them in `LayoutGroup`. This batches layout measurements and ensures sibling components animate together without causing layout shift cascades.

**Incorrect (separate layout animations cause cascading shifts):**

```tsx
function Dashboard() {
  const [expanded, setExpanded] = useState<string | null>(null);

  return (
    <div className="dashboard">
      {/* These animate independently, causing visual jank */}
      <Sidebar expanded={expanded === "sidebar"} />
      <motion.main layout className="content">
        <WidgetGrid />
      </motion.main>
      <NotificationPanel expanded={expanded === "notifications"} />
    </div>
  );
}

function Sidebar({ expanded }: { expanded: boolean }) {
  return (
    <motion.aside layout className="sidebar">
      {expanded && <SidebarDetails />}
    </motion.aside>
  );
}
```

**Correct (grouped animations coordinate measurements):**

```tsx
import { LayoutGroup } from "framer-motion";

function Dashboard() {
  const [expanded, setExpanded] = useState<string | null>(null);

  return (
    <LayoutGroup>
      <div className="dashboard">
        {/* All layout animations now coordinate together */}
        <Sidebar expanded={expanded === "sidebar"} />
        <motion.main layout className="content">
          <WidgetGrid />
        </motion.main>
        <NotificationPanel expanded={expanded === "notifications"} />
      </div>
    </LayoutGroup>
  );
}

function Sidebar({ expanded }: { expanded: boolean }) {
  return (
    <motion.aside layout className="sidebar">
      {expanded && <SidebarDetails />}
    </motion.aside>
  );
}
```

**Use cases for LayoutGroup:**
- Dashboard layouts where expanding one panel affects others
- List items that reorder across multiple parent components
- Multi-column layouts with coordinated animations
- Shared element transitions between sibling components

**Note:** LayoutGroup also enables `layoutId` matching across component boundaries.

Reference: [Framer Motion - LayoutGroup](https://www.framer.com/motion/layout-group/)
