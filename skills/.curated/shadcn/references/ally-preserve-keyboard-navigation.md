---
title: Preserve Keyboard Navigation Patterns
impact: CRITICAL
impactDescription: enables non-mouse users to navigate components
tags: ally, keyboard, navigation, radix, arrow-keys
---

## Preserve Keyboard Navigation Patterns

Radix components implement WAI-ARIA keyboard navigation patterns. Custom styling or structure changes must not break these patterns.

**Incorrect (keyboard navigation broken):**

```tsx
function CustomTabs({ tabs }: { tabs: TabData[] }) {
  const [activeTab, setActiveTab] = useState(0)

  return (
    <div>
      <div className="flex gap-2">
        {tabs.map((tab, index) => (
          <div
            key={tab.id}
            onClick={() => setActiveTab(index)}
            className={activeTab === index ? "border-b-2" : ""}
          >
            {/* div is not focusable, arrow keys don't work */}
            {tab.label}
          </div>
        ))}
      </div>
      <div>{tabs[activeTab].content}</div>
    </div>
  )
}
```

**Correct (shadcn/ui Tabs with full keyboard support):**

```tsx
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs"

function CustomTabs({ tabs }: { tabs: TabData[] }) {
  return (
    <Tabs defaultValue={tabs[0].id}>
      <TabsList>
        {tabs.map((tab) => (
          <TabsTrigger key={tab.id} value={tab.id}>
            {/* Left/Right arrows navigate tabs */}
            {/* Home/End jump to first/last tab */}
            {/* Enter/Space selects tab */}
            {tab.label}
          </TabsTrigger>
        ))}
      </TabsList>
      {tabs.map((tab) => (
        <TabsContent key={tab.id} value={tab.id}>
          {tab.content}
        </TabsContent>
      ))}
    </Tabs>
  )
}
```

**Keyboard patterns by component:**
- **Tabs**: Left/Right arrows, Home/End
- **Menu/Dropdown**: Up/Down arrows, Enter to select
- **Accordion**: Up/Down arrows, Enter to toggle
- **Combobox**: Up/Down arrows, Enter to select, Escape to close

Reference: [WAI-ARIA Patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)
