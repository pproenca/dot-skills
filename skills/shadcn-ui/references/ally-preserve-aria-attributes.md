---
title: Preserve ARIA Attributes from Radix Primitives
impact: CRITICAL
impactDescription: maintains screen reader compatibility
tags: ally, aria, radix, screen-readers, accessibility
---

## Preserve ARIA Attributes from Radix Primitives

Radix primitives automatically manage ARIA attributes for accessibility. Overriding or omitting these attributes breaks screen reader functionality.

**Incorrect (ARIA attributes overridden):**

```tsx
function CustomAccordion({ items }: { items: AccordionItem[] }) {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <div>
      {items.map((item, index) => (
        <div key={item.id}>
          <button
            onClick={() => setOpenIndex(openIndex === index ? null : index)}
          >
            {/* Missing aria-expanded, aria-controls */}
            {item.title}
          </button>
          {openIndex === index && (
            <div>
              {/* Missing aria-labelledby, role="region" */}
              {item.content}
            </div>
          )}
        </div>
      ))}
    </div>
  )
}
```

**Correct (using Radix primitives with automatic ARIA):**

```tsx
import {
  Accordion,
  AccordionContent,
  AccordionItem as AccordionItemComponent,
  AccordionTrigger,
} from "@/components/ui/accordion"

function CustomAccordion({ items }: { items: AccordionItem[] }) {
  return (
    <Accordion type="single" collapsible>
      {items.map((item) => (
        <AccordionItemComponent key={item.id} value={item.id}>
          <AccordionTrigger>
            {/* Radix adds aria-expanded, aria-controls automatically */}
            {item.title}
          </AccordionTrigger>
          <AccordionContent>
            {/* Radix adds aria-labelledby, role="region" automatically */}
            {item.content}
          </AccordionContent>
        </AccordionItemComponent>
      ))}
    </Accordion>
  )
}
```

**ARIA attributes managed by Radix:**
- `aria-expanded` on triggers (Accordion, Collapsible, Dialog)
- `aria-controls` / `aria-labelledby` for content relationships
- `role` attributes (dialog, menu, tablist, etc.)
- `aria-selected` / `aria-checked` for selection states

Reference: [Radix Accessibility](https://www.radix-ui.com/primitives/docs/overview/accessibility)
