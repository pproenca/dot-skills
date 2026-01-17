---
title: JSDoc Documentation
impact: LOW
impactDescription: improves IDE experience and documentation generation
tags: style, jsdoc, documentation, comments
---

## JSDoc Documentation

Add JSDoc comments for component descriptions linking to documentation. Keep comments focused and avoid redundant information.

**Incorrect (verbose or missing):**

```typescript
// Button component
export const Button = React.forwardRef(...)

/**
 * This is a button that can be clicked.
 * It renders a button element.
 * You can pass disabled prop.
 * It supports className.
 */
export const Button = React.forwardRef(...)
```

**Correct (recommended):**

```typescript
/**
 * A button component that can be used to trigger actions.
 * Renders a `<button>` element.
 *
 * Documentation: [Base UI Button](https://base-ui.com/react/components/button)
 */
export const Button = React.forwardRef(function Button(
  componentProps: Button.Props,
  forwardedRef: React.ForwardedRef<HTMLButtonElement>
) {
  // ...
})

/**
 * The root component for an accordion.
 * Manages expansion state for accordion items.
 * Does not render a DOM element.
 *
 * Documentation: [Base UI Accordion](https://base-ui.com/react/components/accordion)
 */
export function AccordionRoot(props: AccordionRoot.Props) {
  // ...
}
```

**When to use:**
- All exported components
- State what element it renders (or if it doesn't render one)
- Link to documentation when available
