---
title: Compose Domain Components From Design System Primitives
impact: MEDIUM
impactDescription: prevents domain screens from re-implementing tokens
tags: domain, composition, primitives, consistency
---

## Compose Domain Components From Design System Primitives

When a domain component like `AppointmentCard` styles itself with raw values, it duplicates card and text styling and drifts from the system the next time tokens change. Building domain components by composing design system primitives (`Card`, `AppText`, `StatusPill`) makes them inherit tokens, theming, and accessibility for free.

**Incorrect (the domain card re-implements styling):**

```typescript
function AppointmentCard({ appointment }: { appointment: Appointment }) {
  return (
    <View style={{ padding: 16, borderRadius: 12, backgroundColor: '#FFFFFF' }}>
      <Text style={{ fontSize: 16, fontWeight: '600', color: '#111827' }}>{appointment.patientName}</Text>
      <Text style={{ fontSize: 13, color: '#6B7280' }}>{appointment.startTime}</Text>
    </View>
  )
}
// The card duplicates card and text styling and drifts from the design system.
```

**Correct (compose Card, AppText, and StatusPill):**

```typescript
function AppointmentCard({ appointment }: { appointment: Appointment }) {
  return (
    <Card tone="default" inset="comfortable">
      <AppText variant="title">{appointment.patientName}</AppText>
      <AppText variant="caption" tone="muted">{appointment.startTime}</AppText>
      <StatusPill status={appointment.status} />
    </Card>
  )
}
// The card inherits tokens, theming, and accessibility from the primitives it composes.
```

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
