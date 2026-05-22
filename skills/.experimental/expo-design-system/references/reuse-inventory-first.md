---
title: Read the Design System Index Before Writing Any Style
impact: HIGH
impactDescription: prevents duplicate components and tokens that fragment the system
tags: reuse, inventory, system-fit, discovery
---

## Read the Design System Index Before Writing Any Style

The default failure is reaching for a fresh `StyleSheet.create` because it is the path of least resistance — without checking what already exists. Before styling anything, read the design system's single index (`packages/design-system/src/index.ts` and the theme tokens): reuse or extend an existing primitive, variant, or token, and create something new only — in the shared package — when nothing fits. The local maximum (a bespoke style that makes one screen look right) is a system loss (a near-duplicate that drifts).

**Incorrect (bespoke card built without checking the system):**

```typescript
// app/appointments/[id].tsx — re-implements a surface the design system already exports
const styles = StyleSheet.create((theme) => ({
  card: { backgroundColor: theme.colors.surfaceRaised, borderRadius: theme.radius.md, padding: theme.space.lg },
}))

function AppointmentDetail({ title }: { title: string }) {
  return <View style={styles.card}><AppText variant="title">{title}</AppText></View>
}
```

**Correct (reuse the indexed primitive):**

```typescript
// The index lists AppCard with tone/inset variants — it already covers this.
import { AppCard, AppText } from '@clinic/design-system'

function AppointmentDetail({ title }: { title: string }) {
  return <AppCard tone="default" inset="comfortable"><AppText variant="title">{title}</AppText></AppCard>
}
```

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
