---
title: Extend Native Element Props Instead of Redeclaring Them
impact: HIGH
impactDescription: inherits every DOM attribute and prevents prop drift
tags: tsx, props, componentprops, dom
---

## Extend Native Element Props Instead of Redeclaring Them

Hand-listing `className`, `onClick`, `disabled`, `aria-*`, etc. on a wrapper component drifts from the DOM definitions and silently drops attributes consumers expect to pass through. `React.ComponentPropsWithRef<"button">` inherits every attribute a real `<button>` accepts (including `ref` in React 19), so the wrapper stays in sync automatically.

**Incorrect (redeclares a subset; the rest can't be passed):**

```tsx
interface ButtonProps {
  onClick: () => void
  className?: string
  disabled?: boolean
  // no type, name, form, aria-* … consumers cannot forward them
}

function Button({ onClick, className, disabled }: ButtonProps) {
  return <button onClick={onClick} className={className} disabled={disabled} />
}
```

**Correct (inherit all native props, add your own):**

```tsx
interface ButtonProps extends React.ComponentPropsWithRef<"button"> {
  variant: "primary" | "secondary"
}

function Button({ variant, className, ...rest }: ButtonProps) {
  return <button className={`btn-${variant} ${className ?? ""}`} {...rest} />
}
```

Use `React.ComponentPropsWithoutRef<"button">` when the component does not forward a ref, and `React.ComponentProps<typeof OtherComponent>` to mirror another component's props.

Reference: [React TypeScript Cheatsheet — Wrapping HTML elements](https://react-typescript-cheatsheet.netlify.app/docs/advanced/patterns_by_usecase/#wrappingmirroring-a-html-element)
