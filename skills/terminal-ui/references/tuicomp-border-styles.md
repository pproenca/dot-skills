---
title: Use Border Styles for Visual Structure
impact: MEDIUM
impactDescription: reduces visual parsing time by 30-50%
tags: tuicomp, borders, styling, visual, box
---

## Use Border Styles for Visual Structure

Use Box borders to create visual grouping and hierarchy. Choose border styles based on emphasis level and terminal compatibility needs.

**Incorrect (manual ASCII borders):**

```typescript
function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box flexDirection="column">
      <Text>+{'-'.repeat(40)}+</Text>
      <Text>| {title.padEnd(39)}|</Text>
      <Text>+{'-'.repeat(40)}+</Text>
      {children}
    </Box>
  )
  // Tedious, error-prone, doesn't adapt to content
}
```

**Correct (Box borderStyle):**

```typescript
function Panel({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box
      flexDirection="column"
      borderStyle="round"
      borderColor="cyan"
      paddingX={1}
    >
      <Text bold>{title}</Text>
      {children}
    </Box>
  )
}
```

**Border style options:**

```typescript
// Available border styles
<Box borderStyle="single">Single line</Box>      // ┌─┐
<Box borderStyle="double">Double line</Box>      // ╔═╗
<Box borderStyle="round">Rounded corners</Box>   // ╭─╮
<Box borderStyle="bold">Bold lines</Box>         // ┏━┓
<Box borderStyle="singleDouble">Mixed</Box>      // ╓─╖
<Box borderStyle="doubleSingle">Mixed</Box>      // ╒═╕
<Box borderStyle="classic">ASCII</Box>           // +-+

// Partial borders
<Box borderTop borderBottom borderStyle="single">
  <Text>Horizontal divider</Text>
</Box>

// Colored borders
<Box borderStyle="round" borderColor="green">
  <Text>Success panel</Text>
</Box>
```

**When NOT to use this pattern:**
- For very constrained terminal widths where borders waste space
- When targeting terminals with limited Unicode support (use `borderStyle="classic"`)

Reference: [Ink Documentation - Box borders](https://github.com/vadimdemedes/ink#borders)
