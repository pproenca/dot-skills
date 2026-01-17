---
title: Use Text Component for All Visible Content
impact: HIGH
impactDescription: prevents 100% of styling bugs from raw strings
tags: tuicomp, text, styling, colors, ink
---

## Use Text Component for All Visible Content

Wrap all visible text in the `Text` component. Never write raw strings directly in JSX as they won't be properly styled or positioned.

**Incorrect (raw strings in JSX):**

```typescript
function Status({ message }: { message: string }) {
  return (
    <Box>
      Status: {message}
      {/* Raw strings may not render correctly */}
    </Box>
  )
}
```

**Correct (Text component for all content):**

```typescript
function Status({ message }: { message: string }) {
  return (
    <Box>
      <Text>Status: </Text>
      <Text color="green">{message}</Text>
    </Box>
  )
}
```

**Text styling options:**

```typescript
// Color (named or hex)
<Text color="cyan">Cyan text</Text>
<Text color="#ff6600">Orange text</Text>

// Background color
<Text backgroundColor="red" color="white">Alert</Text>

// Font styles
<Text bold>Bold text</Text>
<Text italic>Italic text</Text>
<Text underline>Underlined</Text>
<Text strikethrough>Deprecated</Text>

// Dim text for secondary info
<Text dimColor>Less important</Text>

// Inverse colors
<Text inverse> Selected </Text>

// Combined styles
<Text bold color="cyan" underline>Important link</Text>
```

**Note:** Ink handles color support detection automatically. On terminals without color support, styles degrade gracefully.

Reference: [Ink Documentation - Text](https://github.com/vadimdemedes/ink#text)
