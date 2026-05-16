---
title: Restrict `runOnly` to the WCAG levels you commit to
impact: HIGH
impactDescription: reduces noise from AAA and experimental rules nobody plans to meet
tags: axe, a11y, runOnly, wcag
---

## Restrict `runOnly` to the WCAG levels you commit to

axe-core ships ~90 rules across multiple standards: WCAG 2.0/2.1/2.2 levels A/AA/AAA, EN 301 549, Section 508, plus best-practice rules and experimental ones. Running them all produces noise — AAA rules flag patterns that don't belong in the AA bar most teams target, experimental rules change between versions. Set `runOnly` to the rule sets you actually intend to ship against (typically `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa`, plus `best-practice` for catching obvious issues), so violations match your real compliance target.

**Incorrect (no `runOnly` — runs everything including AAA, experimental):**

```ts
const preview: Preview = {
  parameters: {
    a11y: {
      test: 'error',
      // No runOnly: AAA contrast rules and experimental rules will fail builds
    },
  },
};
```

**Correct (explicit AA target — matches what most teams ship):**

```ts
const preview: Preview = {
  parameters: {
    a11y: {
      test: 'error',
      options: {
        runOnly: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'],
      },
    },
  },
};
```

**Common rule sets:**

| Tag | Includes | Use when |
|-----|----------|----------|
| `wcag2a`, `wcag2aa`, `wcag21a`, `wcag21aa` | The standard public-product baseline | Default for most teams |
| `wcag22a`, `wcag22aa` | New 2.2 criteria (focus appearance, target size) | Audit-driven; verify your designs handle 2.2 first |
| `wcag2aaa`, `wcag21aaa` | AAA rules (e.g., 7:1 contrast) | Government / regulated; ensure design system can meet them |
| `best-practice` | Non-WCAG axe heuristics (skip-link, region landmark) | Catches obvious bugs; keep on |
| `experimental` | Unstable rules | Off by default; opt-in for early feedback |
| `section508` | US federal | If targeting US government |

**Per-story override for stricter audits on critical surfaces:**

```tsx
// Login form — held to AAA contrast because of accessibility legal exposure
export const SignIn: Story = {
  parameters: {
    a11y: {
      options: {
        runOnly: ['wcag2a', 'wcag2aa', 'wcag2aaa', 'wcag21a', 'wcag21aa', 'wcag21aaa'],
      },
    },
  },
};
```

**Why this matters:** An a11y suite that fires on AAA rules nobody planned to meet gets ignored. A suite scoped to your actual commitment is one developers fix.

Reference: [axe-core API: runOnly](https://www.deque.com/axe/core-documentation/api-documentation/#options-parameter), [WCAG 2.2 quick reference](https://www.w3.org/WAI/WCAG22/quickref/)
