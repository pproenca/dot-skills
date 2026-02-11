---
title: Use Incremental Compiler Adoption with Directives
impact: CRITICAL
impactDescription: enables safe rollout without full codebase migration
tags: compiler, migration, directives, adoption
---

## Use Incremental Compiler Adoption with Directives

Enabling the React Compiler across an entire codebase at once risks regressions in components that rely on mutation or impure patterns. The `"use memo"` and `"use no memo"` directives give per-file and per-function control, enabling a measured rollout that validates optimization correctness one module at a time.

**Incorrect (all-or-nothing compiler config):**

```tsx
// babel.config.js — compiler applies to every file at once
module.exports = {
  plugins: [
    ["babel-plugin-react-compiler", {}],
  ],
}

// components/LegacyOrderForm.tsx — relies on mutation patterns
function LegacyOrderForm({ order }: { order: Order }) {
  const fields = order.fields
  fields.push({ name: "total", value: order.computeTotal() }) // mutation breaks compiler

  return <FormRenderer fields={fields} />
}

// components/Dashboard.tsx — safe, but no way to enable separately
function Dashboard({ metrics }: { metrics: Metric[] }) {
  const sorted = [...metrics].sort((a, b) => b.value - a.value)
  return <MetricGrid metrics={sorted} />
}
```

**Correct (incremental adoption via directives):**

```tsx
// babel.config.js — compiler runs but respects directives
module.exports = {
  plugins: [
    ["babel-plugin-react-compiler", {
      compilationMode: "annotation", // only compile files that opt in
    }],
  ],
}

// components/Dashboard.tsx — opted in, fully compiler-safe
"use memo"

function Dashboard({ metrics }: { metrics: Metric[] }) {
  const sorted = [...metrics].sort((a, b) => b.value - a.value)
  return <MetricGrid metrics={sorted} />
}

// components/LegacyOrderForm.tsx — explicitly opted out until refactored
"use no memo"

function LegacyOrderForm({ order }: { order: Order }) {
  const fields = order.fields
  fields.push({ name: "total", value: order.computeTotal() })

  return <FormRenderer fields={fields} />
}
```

Reference: [React Compiler — Opting Out](https://react.dev/learn/react-compiler#opting-out-of-react-compiler)
