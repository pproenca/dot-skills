---
title: Use Consistent Spacing Scale
impact: HIGH
impactDescription: creates visual rhythm and reduces design inconsistency
tags: style, spacing, tailwind, consistency, layout
---

## Use Consistent Spacing Scale

Use Tailwind's spacing scale consistently rather than mixing arbitrary values. Consistent spacing creates visual rhythm and professional appearance.

**Incorrect (inconsistent spacing):**

```tsx
function ProfileCard({ user }: { user: User }) {
  return (
    <Card className="p-5">
      <CardHeader className="pb-3">
        <div className="flex gap-[14px] items-center">
          {/* Mixing scales: p-5, pb-3, gap-[14px], mt-[10px] */}
          <Avatar className="h-12 w-12" />
          <div>
            <CardTitle className="mb-[6px]">{user.name}</CardTitle>
            <p className="text-muted-foreground mt-[10px]">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Correct (consistent Tailwind spacing):**

```tsx
function ProfileCard({ user }: { user: User }) {
  return (
    <Card className="p-6">
      <CardHeader className="pb-4">
        <div className="flex gap-4 items-center">
          {/* Consistent scale: p-6, pb-4, gap-4, space-y-1 */}
          <Avatar className="h-12 w-12" />
          <div className="space-y-1">
            <CardTitle>{user.name}</CardTitle>
            <p className="text-muted-foreground">{user.email}</p>
          </div>
        </div>
      </CardHeader>
    </Card>
  )
}
```

**Tailwind spacing scale reference:**
- `1` = 0.25rem (4px)
- `2` = 0.5rem (8px)
- `4` = 1rem (16px)
- `6` = 1.5rem (24px)
- `8` = 2rem (32px)

**Guidelines:**
- Component padding: `p-4` or `p-6`
- Element gaps: `gap-2`, `gap-4`, or `gap-6`
- Section margins: `mt-8`, `mb-12`
- Use `space-y-*` and `space-x-*` for consistent child spacing

Reference: [Tailwind Spacing](https://tailwindcss.com/docs/customizing-spacing)
