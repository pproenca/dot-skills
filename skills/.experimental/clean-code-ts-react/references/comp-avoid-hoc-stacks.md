---
title: Avoid Higher-Order Component Stacks
impact: MEDIUM-HIGH
impactDescription: makes injected dependencies visible and typeable
tags: comp, hoc, hooks, react
---

## Avoid Higher-Order Component Stacks

`withAuth(withTheme(withTracking(withTranslation(Component))))` was the React 16 pattern for sharing cross-cutting behavior. It's nearly always worse than hooks: prop injection is opaque, DevTools shows stacks of `Connect(Connect(Connect(…)))`, and TypeScript inference for the composed props degrades fast. In React 19, hooks are the right answer almost every time.

**Incorrect (HOC stack injects invisible props):**

```tsx
// What props does CheckoutPage actually receive? Read four HOC signatures to find out.
// Type errors point at the outer wrapper, not the real cause.
export default withAuth(
  withTracking(
    withTheme(
      withTranslation(CheckoutPage)
    )
  )
);
```

**Correct (hooks make dependencies visible and typed):**

```tsx
// Dependencies are right at the top of the component, typed, debuggable.
export default function CheckoutPage() {
  const user  = useAuth();
  const track = useTracking();
  const theme = useTheme();
  const { t } = useTranslation();
  // ...use them directly...
  return <main className={theme.background}>{t('checkout.title')}</main>;
}
```

**When NOT to apply this pattern:**
- HOCs you don't own — `Sentry.withErrorBoundary`, `withAuthenticationRequired` from Auth0 — wrap them in one thin component or hook in a single location, don't try to rewrite them.
- HOCs that genuinely transform rendering, not just inject data — a `withSuspense(Component, fallback)` that wraps in `<Suspense>` is acceptable, though `<Suspense>` composition is usually clearer.
- Large legacy codebases — converge gradually; a half-migrated codebase mixing HOCs and hooks is harder to read than either pure form.

**Why this matters:** Visible, typed dependencies at the top of a component beat invisible prop injection from a stack of wrappers — the same readability principle as command-query separation and intention-revealing names.

Reference: [Clean Code, Chapter 10: Classes (substituted: Composition)](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [React Docs: Reusing Logic with Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
