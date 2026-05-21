---
title: Catalog Every Component Variant in Storybook
impact: MEDIUM
impactDescription: prevents undocumented variants from drifting unnoticed
tags: govern, storybook, catalog, review
---

## Catalog Every Component Variant in Storybook

When the only place a button's variants render is deep inside a booking flow, reviewers never see primary, secondary, and danger side by side, so a regression in one variant ships unnoticed. A story that renders every variant in one view makes the component's full surface reviewable and turns visual drift into a caught diff.

**Incorrect (variants only exist inside feature flows):**

```typescript
// the only render of AppButton's variants is buried in a screen
export function BookingScreen() {
  return <AppButton variant="primary" title="Book appointment" onPress={book} />
}
// Reviewers cannot compare variants, so a regression in "danger" slips through.
```

**Correct (a story renders the full variant set):**

```typescript
// AppButton.stories.tsx
export default { title: 'DesignSystem/AppButton', component: AppButton }

export const AllVariants = () => (
  <Card inset="comfortable">
    {(['primary', 'secondary', 'danger'] as const).map((variant) => (
      <AppButton key={variant} variant={variant} title={variant} onPress={() => {}} />
    ))}
  </Card>
)
// Every variant renders side by side, so visual regressions surface in review.
```

Reference: [Building the Airbnb Design System](https://www.infoq.com/news/2020/02/airbnb-design-system-react-conf/)
