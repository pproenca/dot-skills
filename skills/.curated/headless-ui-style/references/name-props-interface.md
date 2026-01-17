---
title: Props Interface as ComponentProps
impact: HIGH
impactDescription: enables consistent type import patterns across all components
tags: name, props, interface, types
---

## Props Interface as ComponentProps

Name props interfaces as `[Component]Props` with the full component name.

**Incorrect (anti-pattern):**

```typescript
interface Props {
  disabled?: boolean
}

interface AccordionRootOptions {
  value?: string[]
}

interface RootProps {
  children: React.ReactNode
}
```

**Correct (recommended):**

```typescript
interface AccordionRootProps {
  children?: React.ReactNode
  value?: string[] | undefined
  defaultValue?: string[] | undefined
  onValueChange?: (value: string[]) => void
  disabled?: boolean | undefined
}

interface AccordionTriggerProps extends BaseUIComponentProps<'button', AccordionTrigger.State> {
  // Additional trigger-specific props
}

interface AccordionPanelProps extends BaseUIComponentProps<'div', AccordionPanel.State> {
  // Additional panel-specific props
}
```

**When to use:**
- All component prop type definitions
- Export via namespace: `export namespace AccordionRoot { export type Props = AccordionRootProps }`
