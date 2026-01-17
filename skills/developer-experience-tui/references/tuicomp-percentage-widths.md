---
title: Use Percentage Widths for Responsive Layouts
impact: HIGH
impactDescription: prevents overflow on 100% of terminal sizes
tags: tuicomp, responsive, width, percentage, layout
---

## Use Percentage Widths for Responsive Layouts

Use percentage-based widths instead of fixed character counts. This ensures layouts adapt to different terminal sizes without overflow or wasted space.

**Incorrect (fixed character widths):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row">
      <Box width={30}>
        <Sidebar />
      </Box>
      <Box width={70}>
        <Content />
      </Box>
    </Box>
  )
  // Breaks on terminals narrower than 100 columns
}
```

**Correct (percentage widths):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row" width="100%">
      <Box width="30%">
        <Sidebar />
      </Box>
      <Box width="70%">
        <Content />
      </Box>
    </Box>
  )
  // Adapts to any terminal width
}
```

**Better (flexGrow for fluid sizing):**

```typescript
function SidebarLayout() {
  return (
    <Box flexDirection="row" width="100%">
      <Box width={20} flexShrink={0}>
        {/* Fixed minimum sidebar */}
        <Sidebar />
      </Box>
      <Box flexGrow={1}>
        {/* Content fills remaining space */}
        <Content />
      </Box>
    </Box>
  )
}
```

**Combining approaches:**

```typescript
function DashboardLayout() {
  return (
    <Box flexDirection="column" width="100%" height="100%">
      <Box height={3} flexShrink={0}>
        <Header />
      </Box>

      <Box flexGrow={1} flexDirection="row">
        <Box width="25%" minWidth={15}>
          <Sidebar />
        </Box>
        <Box flexGrow={1}>
          <MainContent />
        </Box>
      </Box>

      <Box height={1} flexShrink={0}>
        <StatusBar />
      </Box>
    </Box>
  )
}
```

Reference: [Ink Documentation - Box dimensions](https://github.com/vadimdemedes/ink#dimensions)
