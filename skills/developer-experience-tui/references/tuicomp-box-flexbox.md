---
title: Use Box Component with Flexbox for Layouts
impact: HIGH
impactDescription: eliminates manual position calculations
tags: tuicomp, box, flexbox, layout, ink
---

## Use Box Component with Flexbox for Layouts

Use Ink's `Box` component with Flexbox properties for layouts instead of manual character positioning. Flexbox handles alignment, spacing, and responsive sizing automatically.

**Incorrect (manual positioning with spaces):**

```typescript
function Dashboard({ title, status }: { title: string; status: string }) {
  const padding = ' '.repeat(20 - title.length)

  return (
    <Text>
      {title}{padding}{status}
      {'\n'}
      {'='.repeat(40)}
    </Text>
  )
  // Breaks when title length changes
}
```

**Correct (Flexbox layout):**

```typescript
function Dashboard({ title, status }: { title: string; status: string }) {
  return (
    <Box flexDirection="column" width={40}>
      <Box justifyContent="space-between">
        <Text bold>{title}</Text>
        <Text color="green">{status}</Text>
      </Box>
      <Box borderStyle="single" borderBottom />
    </Box>
  )
}
```

**Common Flexbox patterns:**

```typescript
// Centered content
<Box justifyContent="center" alignItems="center" height={10}>
  <Text>Centered</Text>
</Box>

// Sidebar + main content
<Box flexDirection="row" width="100%">
  <Box width="30%"><Sidebar /></Box>
  <Box flexGrow={1}><Content /></Box>
</Box>

// Vertical stack with gaps
<Box flexDirection="column" gap={1}>
  <Header />
  <Content />
  <Footer />
</Box>
```

Reference: [Ink Documentation - Box](https://github.com/vadimdemedes/ink#box)
