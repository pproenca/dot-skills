---
title: Team Conventions Over Personal Preference
impact: HIGH
impactDescription: trades local optimization for codebase-wide consistency, which is what readers actually need
tags: fmt, conventions, consistency, eslint
---

## Team Conventions Over Personal Preference

A codebase where every file follows the same imperfect convention is more readable than one where each author optimized locally with their own perfect convention. New code should look like the surrounding code, even when you disagree, because consistency reduces the cost of context-switching for every reader. Encode the convention in ESLint so it doesn't depend on memory.

**Incorrect (each author chose their own export style):**

```tsx
// File: features/orders/OrderList.tsx
function OrderList({ orders }: { orders: Order[] }) {
  return <ul>{/* ... */}</ul>;
}
export default OrderList;

// File: features/orders/OrderRow.tsx — different convention, same project
export const OrderRow = ({ order }: { order: Order }) => {
  return <li>{order.id}</li>;
};

// File: features/orders/OrderFilters.tsx — a third style
export function OrderFilters(props: { onChange: (f: Filter) => void }) {
  return <form>{/* ... */}</form>;
}
```

Every reader has to re-orient on every file: default vs named, arrow vs function, destructured props vs `props.x`.

**Correct (one convention, applied everywhere, enforced by lint):**

```tsx
// .eslintrc.cjs: 'import/no-default-export', custom rule for named function components.

// File: features/orders/OrderList.tsx
export function OrderList({ orders }: { orders: Order[] }) {
  return <ul>{/* ... */}</ul>;
}

// File: features/orders/OrderRow.tsx
export function OrderRow({ order }: { order: Order }) {
  return <li>{order.id}</li>;
}

// File: features/orders/OrderFilters.tsx
export function OrderFilters({ onChange }: { onChange: (f: Filter) => void }) {
  return <form>{/* ... */}</form>;
}
```

Same shape on every file; readers learn the pattern once.

**When NOT to apply this pattern:**
- When the team convention is actively harmful (e.g., banning `async/await` in favor of `.then` chains, or requiring class components in 2026) — make the case to change it, but until it changes, follow it.
- Greenfield code with no established convention yet — propose one explicitly, write it down, and then start applying it.
- Large legacy migrations: don't reformat 10,000 untouched lines just to align with the new style; let conversion happen as files are touched for real reasons.

**Why this matters:** Consistency is a force multiplier on readability. The "best" rule applied inconsistently is worse than a "good enough" rule applied everywhere.

Reference: [Clean Code, Chapter 5: Formatting — Team Rules](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [ESLint shared configs](https://eslint.org/)
