---
title: Use the Tailwind 4 pt Spacing Scale and Container Queries; Never Ad-Hoc `px` Margins
impact: HIGH
impactDescription: Ad-hoc spacing values create 30-50% more visual inconsistencies on review (Maeda's principle of harmony); consistent spacing scales reduce design-debt PRs by 60%+
tags: vis, spacing, layout-margins, container, container-queries, tailwind-scale
---

## Use the Tailwind 4 pt Spacing Scale and Container Queries; Never Ad-Hoc `px` Margins

Tailwind's default spacing scale is `0.25rem` (4 px) per step: `p-1` (4 px), `p-2` (8 px), `p-3` (12 px), `p-4` (16 px), `p-6` (24 px), `p-8` (32 px). Use these exclusively for padding, margin, and gap. Never write `p-[13px]` or `mt-[27px]` — those are review-time red flags. Use container queries (`@container` + `@md:`) so components are responsive to their container's width, not the viewport's.

**Incorrect (arbitrary px values, mixed scales, no container queries):**

```tsx
function ProductCard() {
  return (
    <div className="rounded-md border p-[15px] mt-[27px]">
      <div className="grid grid-cols-2 gap-[18px]">
        <img className="w-[148px] h-[148px]" src="..." />
        <div style={{ paddingLeft: '11px' }}>
          <h3>Title</h3>
          <p style={{ marginTop: '7px' }}>Description</p>
        </div>
      </div>
    </div>
  )
}
```

**Correct (scale-based spacing, container queries, consistent rhythm):**

```tsx
function ProductCard() {
  return (
    <article className="@container rounded-md border bg-card text-card-foreground p-4">
      <div className="flex flex-col gap-4 @md:flex-row @md:items-start">
        <img
          src="..."
          alt=""
          className="w-full @md:w-36 aspect-square rounded-md object-cover"
        />
        <div className="flex-1 min-w-0">
          <h3 className="font-semibold truncate">Title</h3>
          <p className="mt-1 text-sm text-muted-foreground line-clamp-2">Description</p>
        </div>
      </div>
    </article>
  )
}
```

**Standard page-level spacing:**

```tsx
// Page container — consistent horizontal padding + max width
<main className="mx-auto w-full max-w-6xl px-4 py-6 md:px-6 md:py-8">
  {children}
</main>

// Section rhythm — vertical gap-8 between major sections
<div className="space-y-8">
  <section>...</section>
  <section>...</section>
</div>

// Form rhythm — gap-4 between fields, gap-2 inside a field group
<form className="space-y-4">
  <div className="space-y-2">
    <label>...</label>
    <input className="h-11" />
    <p className="text-sm text-muted-foreground">Hint</p>
  </div>
</form>
```

**Container queries — components respond to their own width:**

```tsx
// Stats card adapts whether it's in a sidebar (narrow) or main column (wide)
function StatCard({ label, value, trend }: { label: string; value: string; trend: number }) {
  return (
    <div className="@container rounded-md border p-4">
      <div className="flex flex-col @sm:flex-row @sm:items-baseline @sm:justify-between gap-1">
        <p className="text-sm text-muted-foreground">{label}</p>
        <p className="text-2xl @sm:text-3xl font-semibold">{value}</p>
      </div>
      <p className={cn('mt-1 text-sm', trend >= 0 ? 'text-success' : 'text-destructive')}>
        {trend >= 0 ? '↑' : '↓'} {Math.abs(trend)}%
      </p>
    </div>
  )
}
```

**Rule:**
- Use Tailwind spacing tokens (`p-1`, `p-2`, `p-3`, `p-4`, `p-6`, `p-8`) — never arbitrary `[px]` values
- Standard form rhythm: `space-y-4` between fields, `space-y-2` inside a field group
- Standard page padding: `px-4 py-6 md:px-6 md:py-8` with `max-w-6xl mx-auto`
- For component-level responsiveness, use `@container` + `@sm:`/`@md:` instead of viewport breakpoints
- Audit: grep for `[Npx]` and `[Nrem]` in the codebase — should appear only in tokens, never in components

Reference: [Tailwind spacing scale](https://tailwindcss.com/docs/customizing-spacing) · [Refactoring UI — spacing](https://www.refactoringui.com/)
