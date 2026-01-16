---
title: Use Stylesheet Precedence for CSS Loading
impact: LOW-MEDIUM
impactDescription: prevents FOUC, ensures correct style ordering
tags: dom, stylesheets, css, precedence
---

## Use Stylesheet Precedence for CSS Loading

React 19 supports stylesheet loading with precedence control. Define loading order and React ensures styles are applied correctly, preventing flash of unstyled content.

**Incorrect (unpredictable style order):**

```tsx
function ComponentWithStyles() {
  return (
    <>
      <link rel="stylesheet" href="/component.css" />
      <link rel="stylesheet" href="/theme.css" />
      <div className="styled-component">...</div>
    </>
  )
}
// Order may vary, theme might not override component styles
```

**Correct (explicit precedence):**

```tsx
function ComponentWithStyles() {
  return (
    <>
      <link
        rel="stylesheet"
        href="/base.css"
        precedence="low"
      />
      <link
        rel="stylesheet"
        href="/component.css"
        precedence="medium"
      />
      <link
        rel="stylesheet"
        href="/theme.css"
        precedence="high"  // Always loads after component styles
      />
      <div className="styled-component">...</div>
    </>
  )
}
```

**With Suspense for style loading:**

```tsx
function StyledSection({ themeUrl }: { themeUrl: string }) {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <link
        rel="stylesheet"
        href={themeUrl}
        precedence="high"
      />
      <ThemedContent />
    </Suspense>
  )
}
// Component suspends until stylesheet is loaded
```

**Built-in precedence levels:**
- `"reset"` - Lowest priority
- `"low"` - Base styles
- `"medium"` - Component styles (default)
- `"high"` - Theme/override styles

Reference: [Stylesheet Precedence](https://react.dev/blog/2024/12/05/react-19#support-for-stylesheets)
