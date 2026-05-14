---
title: Components Are PascalCase Noun Phrases
impact: CRITICAL
impactDescription: enables JSX to render correctly and signals "this is a thing on the page"
tags: name, component, pascal-case, jsx
---

## Components Are PascalCase Noun Phrases

JSX uses the first letter of a tag to distinguish components (`<LoginModal />`) from HTML elements (`<div />`). A lowercase component name is silently treated as an unknown HTML tag and rendered as an empty element — there is no compile error, only a broken UI. Beyond the language rule, components are *things on the page*, so they take noun phrases. Verb-shaped names (`renderHeader`, `showModal`) describe an action and read like functions, not UI pieces.

**Incorrect (lowercase or verb-shaped name — JSX refuses to render or the intent is wrong):**

```tsx
// `loginModal` will be emitted as an unknown HTML tag. React renders nothing useful.
function loginModal({ onClose }: { onClose: () => void }) {
  return <dialog>...</dialog>;
}

// Verb-shaped: reads as an imperative action, not a thing on screen.
function showOrderSummary({ order }: { order: Order }) {
  return <section>{order.id}</section>;
}

// Usage — silently broken at runtime.
<loginModal onClose={handleClose} />;
```

**Correct (PascalCase noun phrase — JSX recognises it, name describes what is rendered):**

```tsx
// React treats capitalized JSX names as component references.
function LoginModal({ onClose }: { onClose: () => void }) {
  return <dialog>...</dialog>;
}

function OrderSummary({ order }: { order: Order }) {
  return <section>{order.id}</section>;
}

// Usage — JSX resolves to the function reference.
<LoginModal onClose={handleClose} />;
```

**When NOT to apply this pattern:**
- Higher-order component factories conventionally use a `withX` lowercase prefix (`withAuth(Component)`) — but in React 19 prefer a custom hook (`useAuth`) over an HOC, sidestepping the question entirely.
- Tagged template helpers (e.g., `styled.button` from styled-components) look like components but are method calls on a factory; they follow the host library's convention, not React's.
- Dynamic component references stored in variables for `<Component />` resolution must still be PascalCase (`const Tag = isLink ? Link : 'button'`) — the constraint applies to the *binding*, not just the source declaration.

**Why this matters:** PascalCase is both a runtime contract with JSX and a semantic signal that lets the reader skim a file and find UI building blocks at a glance.

Reference: [react.dev: Your First Component](https://react.dev/learn/your-first-component), [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
