---
title: Promote a Pattern to the System on Its Second Use
impact: MEDIUM-HIGH
impactDescription: prevents copy-pasted patterns from drifting across features
tags: reuse, promotion, system-fit, governance
---

## Promote a Pattern to the System on Its Second Use

A pattern's first appearance can live in the feature that needs it. Its **second** appearance is the signal to promote it into the design system package — before a third copy exists. Waiting until "later" means three subtly different versions ship and none can be fixed in one place.

**Incorrect (the same badge inlined in two screens):**

```typescript
// appointments/Row.tsx AND patients/Row.tsx both inline this — two StyleSheets that will drift
const styles = StyleSheet.create((theme) => ({
  badge: { backgroundColor: theme.colors.surfaceMuted, borderRadius: theme.radius.sm, paddingHorizontal: theme.space.sm },
}))
```

**Correct (promote on the second occurrence, then import):**

```typescript
// @clinic/design-system/StatusBadge.tsx — extracted once; both screens consume it
import { StatusBadge } from '@clinic/design-system'

<StatusBadge status={appointment.status} />
```

This makes the second instance the trigger — elevating the "when a second instance appears, promote it" aside in [`api-variants-over-style-prop`](api-variants-over-style-prop.md) into a standing rule.

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
