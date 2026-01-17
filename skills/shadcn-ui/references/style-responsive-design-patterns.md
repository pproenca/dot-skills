---
title: Apply Mobile-First Responsive Design
impact: HIGH
impactDescription: prevents mobile usability failures on 50%+ of traffic
tags: style, responsive, mobile-first, breakpoints, tailwind
---

## Apply Mobile-First Responsive Design

Build components mobile-first, then add responsive modifiers for larger screens. This matches Tailwind's design philosophy and ensures mobile usability.

**Incorrect (desktop-first, mobile as afterthought):**

```tsx
function DataTable({ data }: { data: TableRow[] }) {
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead className="w-[200px]">Name</TableHead>
          <TableHead className="w-[150px]">Status</TableHead>
          <TableHead className="w-[200px]">Email</TableHead>
          <TableHead className="text-right w-[100px]">Amount</TableHead>
          {/* All columns visible - table overflows on mobile */}
        </TableRow>
      </TableHeader>
      {/* ... */}
    </Table>
  )
}
```

**Correct (mobile-first with progressive enhancement):**

```tsx
function DataTable({ data }: { data: TableRow[] }) {
  return (
    <div className="w-full overflow-auto">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="min-w-[120px]">Name</TableHead>
            <TableHead className="hidden sm:table-cell">Status</TableHead>
            <TableHead className="hidden md:table-cell">Email</TableHead>
            <TableHead className="text-right">Amount</TableHead>
            {/* Secondary columns hidden on mobile, revealed at breakpoints */}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((row) => (
            <TableRow key={row.id}>
              <TableCell className="font-medium">{row.name}</TableCell>
              <TableCell className="hidden sm:table-cell">
                <Badge variant={row.status === "active" ? "default" : "secondary"}>
                  {row.status}
                </Badge>
              </TableCell>
              <TableCell className="hidden md:table-cell">{row.email}</TableCell>
              <TableCell className="text-right">${row.amount}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  )
}
```

**Responsive patterns:**
- `hidden sm:block` - Hidden on mobile, visible at 640px+
- `flex-col md:flex-row` - Stack on mobile, row on desktop
- `grid-cols-1 lg:grid-cols-3` - Single column to multi-column
- `text-sm md:text-base` - Smaller text on mobile

Reference: [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)
